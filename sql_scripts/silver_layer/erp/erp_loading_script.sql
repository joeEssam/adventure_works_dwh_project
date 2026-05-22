/*
================================================================================
    SILVER LAYER - ERP DATA LOADING SCRIPT
    Purpose: Load and transform ERP source data into silver layer staging tables
    
    This script performs incremental data loads with data cleaning and 
    standardization for all ERP extract files.
    
    Processing Steps:
    1. Extract data from bronze layer ERP tables
    2. Apply data transformations and business logic rules
    3. Standardize codes and values across all ERP sources
    4. Load cleaned data into silver layer tables
================================================================================
*/

USE data_warehouse;

-- =============================================================================
-- LOAD ERP CUSTOMER DATA (AZ12 EXTRACT)
-- =============================================================================

-- Clear existing data and load customer information with transformations
-- Transformations: Remove 'NAS' prefix from CID, validate birth dates, standardize gender codes
PRINT '>>Truncating silver.erp_cust_az12';
TRUNCATE TABLE silver.erp_cust_az12;
PRINT '>>Inserting into silver.erp_cust_az12';

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
         ELSE 'n\a'
    END AS GEN
FROM [data_warehouse].bronze.[erp_cust_az12];

-- =============================================================================
-- LOAD ERP LOCATION DATA (A101 EXTRACT)
-- =============================================================================

-- Clear existing data and load location/geography information with transformations
-- Transformations: Remove hyphens from CID, standardize country codes and names
PRINT '>>Truncating silver.erp_loc_a101';
TRUNCATE TABLE silver.erp_loc_a101;
PRINT '>>Inserting into silver.erp_loc_a101';

INSERT INTO silver.erp_loc_a101 (
    CID,
    CNTRY
)
SELECT
    REPLACE([CID], '-', '') AS CID,
    CASE WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
         WHEN UPPER(CNTRY) = 'DE' THEN 'Germany'
         WHEN CNTRY IS NULL OR TRIM(CNTRY) = '' THEN 'n\a'
         ELSE TRIM(CNTRY)
    END AS CNTRY
FROM [data_warehouse].bronze.[erp_loc_a101];

-- =============================================================================
-- LOAD ERP PRODUCT CATEGORY DATA (PX_CAT_G1V2 EXTRACT)
-- =============================================================================

-- Clear existing data and load product category master information
-- Note: No transformations required for this extract
PRINT '>>Truncating silver.erp_px_cat_g1v2';
TRUNCATE TABLE silver.erp_px_cat_g1v2;
PRINT '>>Inserting into silver.erp_px_cat_g1v2';

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
FROM [data_warehouse].bronze.[erp_px_cat_g1v2];

PRINT '>>ERP data loading completed successfully';
