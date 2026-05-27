
/*
================================================================================
    GOLD LAYER - CUSTOMER DIMENSION VIEW
    Purpose: Customer master data dimension for analysis and segmentation
    
    Source Tables:
    - silver.crm_cust_info: Primary customer data from CRM system
    - silver.erp_cust_az12: Customer demographic data from ERP
    - silver.erp_loc_a101: Customer location data from ERP
    
    Business Logic:
    - Surrogate key: ROW_NUMBER() ordered by customer ID
    - Gender: CRM data is master source; falls back to ERP if not available
================================================================================
*/

CREATE VIEW gold.dim_customer AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,                    -- Surrogate key
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    cl.CNTRY AS country,
    ci.cst_marital_status AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr                             -- CRM is master source
        ELSE COALESCE(ca.GEN, 'n/a')
    END AS gender,
    ca.BDATE AS birthdate,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info AS ci 
LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.CID
LEFT JOIN silver.erp_loc_a101 AS cl
    ON ci.cst_key = cl.CID;


