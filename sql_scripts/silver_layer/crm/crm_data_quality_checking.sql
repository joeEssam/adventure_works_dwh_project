/*
================================================================================
    SILVER LAYER - DATA QUALITY CHECKING SCRIPT
    Purpose: Validate data integrity and identify quality issues in silver layer
    
    This script performs comprehensive data quality checks including:
    - Duplicate detection and null validation
    - Text field trimming verification
    - Referential integrity validation
    - Business logic and calculation verification
    - Date range and format validation
    - Anomaly detection and profiling
================================================================================
*/

USE data_warehouse;
SET NOCOUNT ON;  -- Suppress "rows affected" messages for cleaner output

-- =============================================================================
-- CRM CUSTOMER DATA QUALITY CHECKS
-- =============================================================================

-- Check for duplicate or null customer IDs
SELECT
    cst_id,
    COUNT(*) AS cnt
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for untrimmed customer first names
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Check for untrimmed customer last names
SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Check for untrimmed gender values
SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- Profile distinct gender values in customer data
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

-- Profile distinct marital status values in customer data
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

-- Display all customer records for visual inspection
SELECT *
FROM silver.crm_cust_info;

-- =============================================================================
-- CRM PRODUCT DATA QUALITY CHECKS
-- =============================================================================

-- Display all product records for visual inspection
SELECT *
FROM silver.crm_prd_info;

-- Check for duplicate product IDs
SELECT
    prd_id,
    COUNT(*) AS cnt
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1;

-- Check for untrimmed product names
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for untrimmed product keys
SELECT prd_key
FROM silver.crm_prd_info
WHERE prd_key != TRIM(prd_key);

-- Profile distinct product lines
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- Check for negative or null product costs
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Check for invalid date ranges (start date after end date)
SELECT *
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt;

-- =============================================================================
-- CRM SALES DATA QUALITY CHECKS
-- =============================================================================

-- Check for orphaned product keys (referential integrity violation)
SELECT TOP (1000)
    [sls_ord_num],
    [sls_prd_key],
    [sls_cust_id],
    [sls_order_dt],
    [sls_ship_dt],
    [sls_due_dt],
    [sls_sales],
    [sls_quantity],
    [sls_price]
FROM [data_warehouse].[silver].[crm_sales_details]
WHERE sls_prd_key NOT IN (SELECT prd_key_without_cat FROM [data_warehouse].[silver].[crm_prd_info]);

-- Check for null, empty, or untrimmed order numbers
SELECT sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num IS NULL OR LEN(sls_ord_num) = 0 OR TRIM(sls_ord_num) != sls_ord_num;

-- Check for null, empty, or untrimmed product keys
SELECT sls_prd_key
FROM silver.crm_sales_details
WHERE sls_prd_key IS NULL OR LEN(sls_prd_key) = 0 OR TRIM(sls_prd_key) != sls_prd_key;

-- Check for sales calculation discrepancies and negative values
SELECT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != (sls_quantity * sls_price)
    OR sls_sales <= 0 OR sls_sales IS NULL
    OR sls_quantity <= 0 OR sls_quantity IS NULL
    OR sls_price <= 0 OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price;

-- Check for records with both negative/null price and sales
SELECT *
FROM silver.crm_sales_details
WHERE (sls_price <= 0 OR sls_price IS NULL) AND (sls_sales <= 0 OR sls_sales IS NULL);

-- Identify records with sales calculation errors
SELECT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != (sls_quantity * sls_price)
    OR sls_sales <= 0 OR sls_sales IS NULL
    OR sls_quantity <= 0 OR sls_quantity IS NULL
    OR sls_price <= 0 OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price;
