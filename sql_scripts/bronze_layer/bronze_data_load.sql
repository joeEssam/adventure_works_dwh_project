/*
================================================================================
    BRONZE LAYER - DATA LOAD SCRIPT
    Purpose: Load raw data from CSV files into bronze layer staging tables
================================================================================
*/

-- Call the procedure to execute the data load process
--   EXEC bronze.load_bronze;

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT('================================================================================');
        PRINT('inserting CRM source data...');
        PRINT('================================================================================');

        SET @start_time = GETDATE();
        PRINT('>> truncating table bronze.crm_cust_info');
        TRUNCATE TABLE bronze.crm_cust_info;
        PRINT('>> inserting data into table : bronze.crm_cust_info');
        BULK INSERT bronze.crm_cust_info
        FROM 'D:\data engineering\SQL projects\adventure_works_DWH project\adventure_works_dwh_project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,           -- Skip header row
            FIELDTERMINATOR = ',',  -- CSV delimiter
            TABLOCK                 -- Lock table for faster load
        );
        SET @end_time = GETDATE();
        PRINT('>> loading duration for table bronze.crm_cust_info : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds');

        PRINT('--------------------------------');
        -- Load product information
        SET @start_time = GETDATE();
        PRINT('>> truncating table bronze.crm_prd_info');
        TRUNCATE TABLE bronze.crm_prd_info;
        PRINT('>> inserting data into table : bronze.crm_prd_info');
        BULK INSERT bronze.crm_prd_info
        FROM 'D:\data engineering\SQL projects\adventure_works_DWH project\adventure_works_dwh_project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT('>> loading duration for table bronze.crm_prd_info : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds');

        PRINT('--------------------------------');
        -- Load sales transaction details
        SET @start_time = GETDATE();
        PRINT('>> truncating table bronze.crm_sales_details');
        TRUNCATE TABLE bronze.crm_sales_details;
        PRINT('>> inserting data into table : bronze.crm_sales_details');
        BULK INSERT bronze.crm_sales_details
        FROM 'D:\data engineering\SQL projects\adventure_works_DWH project\adventure_works_dwh_project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT('>> loading duration for table bronze.crm_sales_details : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds');

        PRINT('================================================================================');
        PRINT('inserting ERP source data...');
        PRINT('================================================================================');

        PRINT('--------------------------------');
        -- Loadstomer data from ERP
        SET @start_time = GETDATE();
        PRINT('>> truncating table bronze.erp_cust_az12');
        TRUNCATE TABLE bronze.erp_cust_az12;
        PRINT('>> inserting data into table : bronze.erp_cust_az12');
        BULK INSERT bronze.erp_cust_az12
        FROM 'D:\data engineering\SQL projects\adventure_works_DWH project\adventure_works_dwh_project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT('>> loading duration for table bronze.erp_cust_az12 : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds');

        PRINT('--------------------------------');
        -- Load location/geography data from ERP
        SET @start_time = GETDATE();
        PRINT('>> truncating table bronze.erp_loc_a101');
        TRUNCATE TABLE bronze.erp_loc_a101;
        PRINT('>> inserting data into table : bronze.erp_loc_a101');
        BULK INSERT bronze.erp_loc_a101
        FROM 'D:\data engineering\SQL projects\adventure_works_DWH project\adventure_works_dwh_project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT('>> loading duration for table bronze.erp_loc_a101 : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds');

        PRINT('--------------------------------');
        -- Load product category master from ERP
        SET @start_time = GETDATE();
        PRINT('>> truncating table bronze.erp_px_cat_g1v2');
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        PRINT('>> inserting data into table : bronze.erp_px_cat_g1v2');
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'D:\data engineering\SQL projects\adventure_works_DWH project\adventure_works_dwh_project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT('>> loading duration for table bronze.erp_px_cat_g1v2 : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds');
        SET @batch_end_time = GETDATE();
        
        PRINT('================================================================================');
        PRINT('>> the batch loading total duration : ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(10)) + ' seconds');
        
        -- =============================================================================
        -- VERIFICATION QUERIES
        -- =============================================================================
        PRINT('================================================================================');
        PRINT('Data load complete. Sample records from each table for verification');
        PRINT('================================================================================');
        SELECT TOP 10 * FROM bronze.crm_cust_info;
        SELECT TOP 10 * FROM bronze.crm_prd_info;
        SELECT TOP 10 * FROM bronze.crm_sales_details;
        SELECT TOP 10 * FROM bronze.erp_cust_az12;
        SELECT TOP 10 * FROM bronze.erp_loc_a101;
        SELECT TOP 10 * FROM bronze.erp_px_cat_g1v2;
    
    END TRY
    BEGIN CATCH
        PRINT('================================================================================');
        PRINT('Error occurred during bronze layer data load');
        PRINT('Error Message: ' + ERROR_MESSAGE());
        PRINT('Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10)));
        PRINT('Error Severity: ' + CAST(ERROR_SEVERITY() AS NVARCHAR(10)));
        PRINT('================================================================================');
    END CATCH;
END;

