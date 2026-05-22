/*
================================================================================
    SILVER LAYER - CRM DATA LOADING SCRIPT
    Purpose: Load and transform CRM source data into silver layer staging tables
    
    This script performs incremental data loads with data cleaning, deduplication,
    and standardization for all CRM extract files.
    
    Processing Steps:
    1. Extract data from bronze layer CRM tables
    2. Apply data transformations and business logic rules
    3. Remove duplicate records and null values
    4. Standardize codes and values across all CRM sources
    5. Load cleaned data into silver layer tables
================================================================================
*/

USE data_warehouse;
SET NOCOUNT ON;  -- Suppress "rows affected" messages for cleaner output

-- =============================================================================
-- LOAD CRM CUSTOMER INFORMATION
-- =============================================================================

-- Clear existing data and load customer information with transformations and deduplication
-- Transformations: Trim text fields, standardize marital status and gender codes
-- Deduplication: Keep most recent record per customer based on creation date
TRUNCATE TABLE silver.crm_cust_info;
PRINT 'Inserting into silver.crm_cust_info';

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
         ELSE 'n\a'
    END AS cst_marital_status,
    CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
         WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
         ELSE 'n\a'
    END AS cst_gndr,
    cst_create_date
FROM (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS dublication_flag
    FROM bronze.crm_cust_info
) AS t
WHERE dublication_flag = 1 AND cst_id IS NOT NULL;

-- =============================================================================
-- LOAD CRM PRODUCT INFORMATION
-- =============================================================================

-- Clear existing data and load product information with transformations
-- Transformations: Extract product category from key, trim text fields, standardize product line codes
-- Date Logic: Calculate end date as day before next product version start date
TRUNCATE TABLE silver.crm_prd_info;
PRINT 'Inserting into silver.crm_prd_info';

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

-- =============================================================================
-- LOAD CRM SALES TRANSACTION DETAILS
-- =============================================================================

-- Clear existing data and load sales transaction details with data cleansing
-- Transformations: Convert integer dates to DATE format, validate and correct sales calculations
-- Date Validation: Set invalid dates (zero or wrong format) to NULL
-- Sales Calculation: Recalculate sales amount if discrepancy detected between quantity * price
-- Price Validation: Recalculate unit price if negative or zero values detected
TRUNCATE TABLE silver.crm_sales_details;
PRINT 'Inserting into silver.crm_sales_details';

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
FROM [data_warehouse].[bronze].[crm_sales_details];

PRINT 'CRM data loading completed successfully';