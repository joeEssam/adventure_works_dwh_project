/*
================================================================================
    SILVER LAYER - DATA LOADING PROCEDURE
    Purpose: Load and transform CRM and ERP source data into silver layer tables
    with data cleaning, deduplication, and standardization
================================================================================
*/
/*
    EXECUTION EXAMPLE:
        EXEC silver.load_silver;
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY

        SET @batch_start_time = GETDATE();
        PRINT('================================================================================');
        PRINT('Inserting CRM data into silver layer...');
        PRINT('================================================================================');
        
        -- =============================================================================
        -- LOAD CRM CUSTOMER INFORMATION
        -- =============================================================================

        -- Clear existing data and load customer information with transformations and deduplication
        -- Transformations: Trim text fields, standardize marital status and gender codes
        -- Deduplication: Keep most recent record per customer based on creation date
        
        SET @start_time = GETDATE();
        PRINT('>> Truncating silver.crm_cust_info');
        TRUNCATE TABLE silver.crm_cust_info;
        PRINT('>> Inserting into silver.crm_cust_info');

        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
            CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END AS cst_marital_status,
            CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END AS cst_gndr,
            cst_create_date
        FROM (
            SELECT *,
            ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS dublication_flag
            FROM bronze.crm_cust_info
        ) AS t
        WHERE dublication_flag = 1 AND cst_id IS NOT NULL;
        
        SET @end_time = GETDATE();
        PRINT('>> loading duration for table silver.crm_cust_info : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds');
        PRINT('--------------------------------');

        -- =============================================================================
        -- LOAD CRM PRODUCT INFORMATION
        -- =============================================================================

        -- Clear existing data and load product information with transformations
        -- Transformations: Extract product category from key, trim text fields, standardize product line codes
        -- Date Logic: Calculate end date as day before next product version start date
        
        SET @start_time = GETDATE();
        PRINT('>> Truncating silver.crm_prd_info');
        TRUNCATE TABLE silver.crm_prd_info;
        PRINT('>> Inserting into silver.crm_prd_info');

        INSERT INTO silver.crm_prd_info (
            prd_id,
            prd_cat,
            prd_key,
            prd_key_without_cat,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS prd_cat,
            TRIM(prd_key) AS prd_key,
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key_without_cat,
            TRIM(prd_nm) AS prd_nm,
            COALESCE(prd_cost, 0) AS prd_cost,
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'T' THEN 'Touring'
                WHEN 'S' THEN 'other sales'
                ELSE 'n/a'
            END AS prd_line,
            CAST(prd_start_dt AS DATE),
            CAST(DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS DATE) AS prd_end_dt
        FROM bronze.crm_prd_info;
        
        SET @end_time = GETDATE();
        PRINT('>> loading duration for table silver.crm_prd_info : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds');
        PRINT('--------------------------------');

        -- =============================================================================
        -- LOAD CRM SALES TRANSACTION DETAILS
        -- =============================================================================

        -- Clear existing data and load sales transaction details with data cleansing
        -- Transformations: Convert integer dates to DATE format, validate and correct sales calculations
        -- Date Validation: Set invalid dates (zero or wrong format) to NULL
        -- Sales Calculation: Recalculate sales amount if discrepancy detected between quantity * price
        -- Price Validation: Recalculate unit price if negative or zero values detected

        SET @start_time = GETDATE();
        PRINT('>> Truncating silver.crm_sales_details');
        TRUNCATE TABLE silver.crm_sales_details;
        PRINT('>> Inserting into silver.crm_sales_details');

        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END AS sls_order_dt,
            CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END AS sls_ship_dt,
            CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END AS sls_due_dt,
            CASE WHEN sls_sales != (sls_quantity * ABS(sls_price)) OR sls_sales IS NULL OR sls_sales <= 0
                THEN (sls_quantity * ABS(sls_price))
                ELSE sls_sales
            END AS sls_sales,
            sls_quantity,
            CASE WHEN sls_price IS NULL OR sls_price <= 0
                THEN (ABS(sls_sales) / NULLIF(sls_quantity, 0))
                ELSE sls_price
            END AS sls_price
        FROM data_warehouse.bronze.crm_sales_details;
        
        SET @end_time = GETDATE();
        PRINT('>> loading duration for table silver.crm_sales_details : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds');
        
        
        PRINT('>> CRM data loading completed successfully');
        SET @batch_end_time = GETDATE();
        PRINT('================================================================================');
        PRINT('>> Batch loading total duration : ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(10)) + ' seconds');
            
        -- =============================================================================
        -- LOAD ERP CUSTOMER DATA (AZ12 EXTRACT)
        -- =============================================================================

        -- Clear existing data and load customer information with transformations
        -- Transformations: Remove 'NAS' prefix from CID, validate birth dates, standardize gender codes
        SET @batch_start_time = GETDATE();
        PRINT('================================================================================');
        PRINT('Inserting ERP source data...');
        PRINT('================================================================================');
        
        SET @start_time = GETDATE();
        PRINT('>> Truncating silver.erp_cust_az12');
        TRUNCATE TABLE silver.erp_cust_az12;
        PRINT('>> Inserting into silver.erp_cust_az12');

        INSERT INTO silver.erp_cust_az12 (
            CID,
            BDATE,
            GEN
        )
        SELECT
            CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID))
                ELSE CID
            END AS CID,
            CASE WHEN BDATE NOT BETWEEN '1900-01-01' AND GETDATE() THEN NULL
                ELSE BDATE
            END AS BDATE,
            CASE WHEN UPPER(GEN) IN ('M', 'MALE') THEN 'Male'
                WHEN UPPER(GEN) IN ('F', 'FEMALE') THEN 'Female'
                ELSE 'n/a'
            END AS GEN
        FROM data_warehouse.bronze.erp_cust_az12;
        
        SET @end_time = GETDATE();
        PRINT('>> loading duration for table silver.erp_cust_az12 : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds');
        PRINT('--------------------------------');

        -- =============================================================================
        -- LOAD ERP LOCATION DATA (A101 EXTRACT)
        -- =============================================================================

        -- Clear existing data and load location/geography information with transformations
        -- Transformations: Remove hyphens from CID, standardize country codes and names
        
        SET @start_time = GETDATE();
        PRINT('>> Truncating silver.erp_loc_a101');
        TRUNCATE TABLE silver.erp_loc_a101;
        PRINT('>> Inserting into silver.erp_loc_a101');

        INSERT INTO silver.erp_loc_a101 (
            CID,
            CNTRY
        )
        SELECT
            REPLACE([CID], '-', '') AS CID,
            CASE WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
                WHEN UPPER(CNTRY) = 'DE' THEN 'Germany'
                WHEN CNTRY IS NULL OR TRIM(CNTRY) = '' THEN 'n/a'
                ELSE TRIM(CNTRY)
            END AS CNTRY
        FROM data_warehouse.bronze.erp_loc_a101;

        SET @end_time = GETDATE();
        PRINT('>> loading duration for table silver.erp_loc_a101 : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds');
        PRINT('--------------------------------');

        -- =============================================================================
        -- LOAD ERP PRODUCT CATEGORY DATA (PX_CAT_G1V2 EXTRACT)
        -- =============================================================================

        -- Clear existing data and load product category master information
        -- Note: No transformations required for this extract
        
        SET @start_time = GETDATE();
        PRINT('>> Truncating silver.erp_px_cat_g1v2');
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        PRINT('>> Inserting into silver.erp_px_cat_g1v2');

        INSERT INTO silver.erp_px_cat_g1v2 (
            ID,
            CAT,
            SUBCAT,
            MAINTENANCE
        )
        SELECT
            ID,
            CAT,
            SUBCAT,
            MAINTENANCE
        FROM data_warehouse.bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();
        PRINT('>> loading duration for table silver.erp_px_cat_g1v2 : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds');
        
        SET @batch_end_time = GETDATE();
        PRINT('--------------------------------');
        PRINT('>> ERP data loading completed successfully');
        PRINT('================================================================================');
        PRINT('>> Batch loading total duration : ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(10)) + ' seconds');
        
        -- =============================================================================
        -- VERIFICATION QUERIES
        -- =============================================================================
        PRINT('================================================================================');
        PRINT('Data load complete. Sample records from each table for verification');
        PRINT('================================================================================');
        SELECT TOP 10 * FROM silver.crm_cust_info;
        SELECT TOP 10 * FROM silver.crm_prd_info;
        SELECT TOP 10 * FROM silver.crm_sales_details;
        SELECT TOP 10 * FROM silver.erp_cust_az12;
        SELECT TOP 10 * FROM silver.erp_loc_a101;
        SELECT TOP 10 * FROM silver.erp_px_cat_g1v2;
    
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