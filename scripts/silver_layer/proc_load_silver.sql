USE [DataWarehouse]
GO
/****** Object:  StoredProcedure Load silver layer (Bronze -> Silver)  
  =======================================================================================
  This stored procedure performs the ETL ( Extract, Transform, Load) process to populate 
  tables in the silver schema from the bronze schema.
  
  Action Steps:
  - Truncate Silver layer tables.
  - Insert cleaned and transformed data from the bronze layer table into the silver tables

  Parameter:
  - None

  Usage:
   EXEC silver.load_silver;
  =======================================================================================
  Script Date: 10/06/2025 20:18:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN

	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '=======================================================================';
		PRINT 'Loading Silver Layer';
		PRINT '=======================================================================';

		PRINT '-----------------------------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '-----------------------------------------------------------------------';

		--TABLE 1
		---Load CUST Table
		-- To ensure table is empty for a new full load

		SET @start_time = GETDATE();

	PRINT '>> Truncating Table: silver.crm_cust_info';
	TRUNCATE TABLE silver.crm_cust_info;

	PRINT '>> INSERTING DATA INTO : silver.crm_cust_info';

	INSERT INTO silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date)
	SELECT 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	CASE WHEN UPPER(TRIM(cst_marital_status)) ='S' THEN 'Single'
	WHEN UPPER(TRIM(cst_marital_status)) ='M' THEN 'Married'
	ELSE 'n/a'
	END cst_marital_status,
	CASE WHEN UPPER(TRIM(cst_gndr)) ='F' THEN 'Female'
	WHEN UPPER(TRIM(cst_gndr)) ='M' THEN 'Male'
	ELSE 'n/a'
	END cst_gndr,
	cst_create_date
	FROM bronze.crm_cust_info;

	DELETE FROM silver.crm_cust_info
	WHERE cst_id IS NULL;

	SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';


	----------------------------------------------------

	SET @start_time = GETDATE();

	PRINT '>> Truncating Table: silver.crm_prd_info';
	TRUNCATE TABLE silver.crm_prd_info;

	PRINT '>> INSERTING DATA INTO : silver.crm_prd_info';

	INSERT INTO silver.crm_prd_info (
	prd_id
	,prd_cat_id
	,prd_key
	,prd_nm
	,prd_cost
	,prd_line
	,prd_start_dt
	,prd_end_dt)
	SELECT 
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS prd_cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,
	CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
	WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
	WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
	WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
	ELSE 'n/a'
	END AS prd_line,
	CAST (prd_start_dt AS DATE) AS prd_start_dt,
	CAST (LEAD (prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
	FROM bronze.crm_prd_info;

	SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

	-----------------------------------------------

	SET @start_time = GETDATE();

	PRINT '>> Truncating Table: silver.crm_sales_details';
	TRUNCATE TABLE silver.crm_sales_details;

	PRINT '>> INSERTING DATA INTO : silver.crm_sales_details';

	INSERT INTO silver.crm_sales_details(
	sls_ord_num
	,sls_prd_key
	,sls_cust_id
	,sls_order_dt
	,sls_ship_dt
	,sls_due_dt
	,sls_sales
	,sls_quantity
	,sls_price
	)
	SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
	ELSE CAST (CAST(sls_order_dt AS VARCHAR) AS DATE)
	END sls_order_dt,
	CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
	ELSE CAST (CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END sls_ship_dt,
	CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
	ELSE CAST (CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END sls_due_dt,
	CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
	THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
	END sls_sale,
	sls_quantity,
	CASE WHEN sls_price IS NULL OR sls_price <= 0
	THEN sls_sales/ sls_quantity
	ELSE sls_price
	END sls_price
	FROM bronze.crm_sales_details;

	SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

	----------------------------------------------------------
	
		PRINT '-----------------------------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '-----------------------------------------------------------------------';

	SET @start_time = GETDATE();

	PRINT '>> Truncating Table: silver.erp_cust_az12';
	TRUNCATE TABLE silver.erp_cust_az12;

	PRINT '>> INSERTING DATA INTO : silver.erp_cust_az12';

	INSERT INTO silver.erp_cust_az12(cid,bdate,gen)
	SELECT 
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	ELSE cid
	END AS cid,
	CASE WHEN bdate > GETDATE() THEN NULL
	ELSE bdate
	END bdate,
	CASE WHEN UPPER(TRIM(gen)) IN ('F', 'Female') THEN 'Female'
	WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
	ELSE 'n/a'
	END gen
	FROM bronze.erp_cust_az12;

	SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

	-----------------------------

	SET @start_time = GETDATE();

	PRINT '>> Truncating Table: silver.erp_loc_a101';
	TRUNCATE TABLE silver.erp_loc_a101;

	PRINT '>> INSERTING DATA INTO : silver.erp_loc_a101';

	INSERT INTO silver.erp_loc_a101(cid,cntry)
	SELECT 
	REPLACE (cid, '-', '') cid,
	CASE WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United State'
	WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
	WHEN UPPER(TRIM(cntry)) IN ('', NULL) THEN 'n/a'
	ELSE cntry
	END cntry
	FROM bronze.erp_loc_a101;

	SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

	----------------------------

	SET @start_time = GETDATE();

	PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
	TRUNCATE TABLE silver.erp_px_cat_g1v2;

	PRINT '>> INSERTING DATA INTO : silver.erp_px_cat_g1v2';

	INSERT INTO silver.erp_px_cat_g1v2 (id,cat,subcat,maintenance)
	SELECT id,
	cat,
	subcat,
	maintenance
	FROM bronze.erp_px_cat_g1v2;

	SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @batch_end_time = GETDATE();
		PRINT '================================================================='
		PRINT 'LOADING Silver LAYER is completed';
		PRINT '		-  Total Load Duration: ' +  CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '================================================================='
	END TRY
	BEGIN CATCH
		PRINT '================================================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '================================================================='
	END CATCH

END
