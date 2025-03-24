/*
============================================================

Create Database and Schemas
============================================================
Purpose of Script:
    This script creates a new database named 'DataWarehouse' after checking if it does exist.
    If the database exists, it will be dropped and a new one will be recreated. Additionally, 
    the script sets up three schemas within the database: 'bronze', 'silver', and 'gold'.

WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it already exists.
    All data in the database will be permanently deleted. Proceed with caution and ensure 
    you have proper backups before running this script.

*/

-- Create Database 'DataWarehouse'

Use master;
GO

-- Drop and recreate the 'DataWarehouse' database
If EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
  ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE DataWarehouse;
END;
GO

-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO
  
USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO
  
CREATE SCHEMA silver;
GO
  
CREATE SCHEMA gold;
GO
