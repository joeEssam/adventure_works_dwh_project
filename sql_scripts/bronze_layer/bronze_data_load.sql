/*
================================================================================
    BRONZE LAYER - DATA LOAD SCRIPT
    Purpose: Load raw data from CSV files into bronze layer staging tables
    
    ⚠️  WARNING: This script will TRUNCATE all bronze layer tables.
         All existing data in these tables will be permanently deleted.
         Only the current batch of data from the source files will remain.
         Ensure backups are available before executing this script.
================================================================================
*/

USE data_warehouse;
SET NOCOUNT ON;  -- Suppress "rows affected" messages for cleaner output

-- =============================================================================
-- CRM SOURCE DATA LOADS
-- =============================================================================

-- Load customer information
TRUNCATE TABLE bronze.crm_cust_info;
BULK INSERT bronze.crm_cust_info
FROM 'D:\data engineering\SQL projects\adventure_works_DWH project\adventure_works_dwh_project\datasets\source_crm\cust_info.csv'
WITH (
    FIRSTROW = 2,           -- Skip header row
    FIELDTERMINATOR = ',',  -- CSV delimiter
    TABLOCK                 -- Lock table for faster load
);

-- Load product information
TRUNCATE TABLE bronze.crm_prd_info;
BULK INSERT bronze.crm_prd_info
FROM 'D:\data engineering\SQL projects\adventure_works_DWH project\adventure_works_dwh_project\datasets\source_crm\prd_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

-- Load sales transaction details
TRUNCATE TABLE bronze.crm_sales_details;
BULK INSERT bronze.crm_sales_details
FROM 'D:\data engineering\SQL projects\adventure_works_DWH project\adventure_works_dwh_project\datasets\source_crm\sales_details.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

-- =============================================================================
-- ERP SOURCE DATA LOADS
-- =============================================================================

-- Load customer data from ERP
TRUNCATE TABLE bronze.erp_cust_az12;
BULK INSERT bronze.erp_cust_az12
FROM 'D:\data engineering\SQL projects\adventure_works_DWH project\adventure_works_dwh_project\datasets\source_erp\CUST_AZ12.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

-- Load location/geography data from ERP
TRUNCATE TABLE bronze.erp_loc_a101;
BULK INSERT bronze.erp_loc_a101
FROM 'D:\data engineering\SQL projects\adventure_works_DWH project\adventure_works_dwh_project\datasets\source_erp\LOC_A101.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

-- Load product category master from ERP
TRUNCATE TABLE bronze.erp_px_cat_g1v2;
BULK INSERT bronze.erp_px_cat_g1v2
FROM 'D:\data engineering\SQL projects\adventure_works_DWH project\adventure_works_dwh_project\datasets\source_erp\PX_CAT_G1V2.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

-- =============================================================================
-- VERIFICATION QUERIES
-- =============================================================================

SELECT TOP 10 * FROM bronze.crm_cust_info;
SELECT TOP 10 * FROM bronze.crm_prd_info;
SELECT TOP 10 * FROM bronze.crm_sales_details;
SELECT TOP 10 * FROM bronze.erp_cust_az12;
SELECT TOP 10 * FROM bronze.erp_loc_a101;
SELECT TOP 10 * FROM bronze.erp_px_cat_g1v2;