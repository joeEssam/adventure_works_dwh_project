/*
================================================================================
    GOLD LAYER - DATA QUALITY VALIDATION SCRIPT
    Purpose: Validate data integrity and identify quality issues in gold layer
    
    Checks performed:
    - Data completeness: Review all records
    - Uniqueness validation: Detect duplicate keys
    - Referential integrity: Find orphaned facts
    - Data profiling: Analyze distinct values
================================================================================
*/

USE data_warehouse;
SET NOCOUNT ON;

-- =============================================================================
-- CUSTOMER DIMENSION - DATA REVIEW AND VALIDATION
-- =============================================================================

-- Display all customer records
SELECT * FROM gold.dim_customer;

-- Profile distinct gender values
SELECT DISTINCT gender FROM gold.dim_customer;

-- =============================================================================
-- PRODUCT DIMENSION - DATA REVIEW AND VALIDATION
-- =============================================================================

-- Display all product records
SELECT * FROM gold.dim_products;

-- Check for duplicate product keys
SELECT 
    product_key, 
    COUNT(*) AS cnt 
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- =============================================================================
-- FACT SALES - COMPLETENESS AND REFERENTIAL INTEGRITY CHECKS
-- =============================================================================

-- Display all sales fact records
SELECT * FROM gold.fact_sales;

-- Check for missing customer keys (orphaned facts)
SELECT * 
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customer AS c 
    ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;

-- Check for missing product keys (orphaned facts)
SELECT * 
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL;

-- Complete data validation: All facts with both dimensions
SELECT * 
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customer AS c 
    ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key;