/*
================================================================================
    SILVER LAYER - DATA QUALITY VALIDATION SCRIPT
    Purpose: Validate data integrity and identify quality issues in silver layer
    
    Checks performed:
    - Duplicate and null value detection
    - Text field trimming verification
    - Referential integrity validation
    - Business logic and calculation verification
    - Date range and format validation
    - Data profiling and anomaly detection
================================================================================
*/

USE data_warehouse;
SET NOCOUNT ON;

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

-- Profile distinct gender values
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

-- Profile distinct marital status values
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

-- Display all customer records
SELECT *
FROM silver.crm_cust_info;

-- =============================================================================
-- CRM PRODUCT DATA QUALITY CHECKS
-- =============================================================================

-- Display all product records
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

-- =============================================================================
-- ERP CUSTOMER DATA QUALITY CHECKS (AZ12 EXTRACT)
-- =============================================================================

-- Check for customer IDs not in CRM customer master
SELECT
    CID,
    BDATE,
    GEN
FROM [data_warehouse].silver.[erp_cust_az12]
WHERE CID NOT IN (SELECT cst_key FROM silver.crm_cust_info); 

-- Check for invalid birth dates outside acceptable range
SELECT *
FROM [data_warehouse].silver.[erp_cust_az12]
WHERE BDATE NOT BETWEEN '1900-01-01' AND '2024-12-31';


-- Check for untrimmed gender values
SELECT *
FROM [data_warehouse].silver.[erp_cust_az12]
WHERE GEN != TRIM(GEN);

-- Profile distinct gender values
SELECT DISTINCT GEN FROM [data_warehouse].silver.[erp_cust_az12];

-- Check for invalid gender values (should be Male, Female, or n/a)
SELECT *
FROM [data_warehouse].silver.[erp_cust_az12]
WHERE TRIM(GEN) NOT IN ('Male', 'Female', 'n/a');

-- =============================================================================
-- ERP LOCATION DATA QUALITY CHECKS (A101 EXTRACT)
-- =============================================================================

-- Check for null or missing CID or CNTRY values
SELECT *
FROM [data_warehouse].silver.[erp_loc_a101]
WHERE CID IS NULL OR CNTRY IS NULL;

-- Check for untrimmed country values
SELECT *
FROM [data_warehouse].silver.[erp_loc_a101]
WHERE CNTRY != TRIM(CNTRY);

-- Profile distinct country values
SELECT DISTINCT CNTRY FROM [data_warehouse].silver.[erp_loc_a101];

-- Check for untrimmed CID values
SELECT *
FROM [data_warehouse].silver.[erp_loc_a101]
WHERE CID != TRIM(CID);

-- =============================================================================
-- ERP PRODUCT CATEGORY DATA QUALITY CHECKS (PX_CAT_G1V2 EXTRACT)
-- =============================================================================

-- Check for product categories not in CRM product master
SELECT *
FROM [data_warehouse].silver.[erp_px_cat_g1v2]
WHERE ID NOT IN (SELECT prd_cat FROM [data_warehouse].silver.crm_prd_info);

-- Check for untrimmed values in category fields
SELECT *
FROM [data_warehouse].silver.[erp_px_cat_g1v2]
WHERE ID != TRIM(ID) OR CAT != TRIM(CAT) OR SUBCAT != TRIM(SUBCAT) OR MAINTENANCE != TRIM(MAINTENANCE);

-- Profile distinct category values
SELECT DISTINCT CAT FROM [data_warehouse].silver.[erp_px_cat_g1v2];

-- Profile distinct subcategory values
SELECT DISTINCT SUBCAT FROM [data_warehouse].silver.[erp_px_cat_g1v2];

-- Profile distinct maintenance values
SELECT DISTINCT MAINTENANCE FROM [data_warehouse].silver.[erp_px_cat_g1v2];