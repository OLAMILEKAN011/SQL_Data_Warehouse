/*
=================================================================================================
Stored Procedure Script: Load Bronze Layer (Source -> Bronze)
=================================================================================================
Purpose of Script:
	This stored procedure script loads data into the 'bronze' schema from external CSV files. 
	It performs the following:
	- Truncates the bronze tables before loading new data.
	- It uses the 'BULK INSERT' command to load data from CSV files to 'bronze' tables.

Parameters:
	- None
	This stored procedure does not accept any parameters or return and values.

Usage:
	EXEC bronze.load_bronze;
=================================================================================================
*/



--Create a stored procedure for repetitive data load.

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '=======================================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '=======================================================================';

		PRINT '-----------------------------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '-----------------------------------------------------------------------';

		--TABLE 1
		---Load CUST Table
		-- To ensure table is empty for a new full load

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		-- Load bulk data into empty table
		PRINT '>> Inserting Data into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\olami\Downloads\SQL Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';


		-------------------------------------------------


		--TABLE 2
		---Load PRD Table
		-- To ensure table is empty for a new full load

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		-- Load bulk data into empty table
		PRINT '>> Inserting Data into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\olami\Downloads\SQL Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		-------------------------------------------------


		--TABLE 3
		---Load Sales_details Table
		-- To ensure table is empty for a new full load

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		-- Load bulk data into empty table
		PRINT '>> Inserting Data into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\olami\Downloads\SQL Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';


		-------------------------------------------------
		PRINT '-----------------------------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '-----------------------------------------------------------------------';

		--TABLE 4
		---Load CUST_AZ12 Table
		-- To ensure table is empty for a new full load
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		-- Load bulk data into empty table
		PRINT '>> Inserting Data into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\olami\Downloads\SQL Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';


		-------------------------------------------------


		--TABLE 5
		---Load LOC_A101 Table
		-- To ensure table is empty for a new full load
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		-- Load bulk data into empty table
		PRINT '>> Inserting Data into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\olami\Downloads\SQL Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';


		-------------------------------------------------


		--TABLE 6
		---Load PX_CAT_G1V2 Table
		-- To ensure table is empty for a new full load
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		-- Load bulk data into empty table

		PRINT '>> Inserting Data into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\olami\Downloads\SQL Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @batch_end_time = GETDATE();
		PRINT '================================================================='
		PRINT 'LOADING BRONZE LAYER is completed';
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




--- Execute Stored procedure
EXEC bronze.load_bronze







	-- Checking data quality 
	SELECT * FROM bronze.crm_cust_info;

	SELECT COUNT(*) FROM bronze.crm_cust_info;

-- Checking data quality 
	SELECT * FROM bronze.crm_prd_info;

	SELECT COUNT(*) FROM bronze.crm_prd_info;

	-- Checking data quality 
	SELECT * FROM bronze.crm_sales_details;

	SELECT COUNT(*) FROM bronze.crm_sales_details;

	-- Checking data quality 
	SELECT * FROM bronze.erp_cust_az12;

	SELECT COUNT(*) FROM bronze.erp_cust_az12;

	-- Checking data quality 
	SELECT * FROM bronze.erp_loc_a101;

	SELECT COUNT(*) FROM bronze.erp_loc_a101;
	
	-- Checking data quality 
	SELECT * FROM bronze.erp_px_cat_g1v2;

	SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2;
