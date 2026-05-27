
/*
================================================================================
    GOLD LAYER - PRODUCT DIMENSION VIEW
    Purpose: Product master data dimension for categorization and product analysis
    
    Source Tables:
    - silver.crm_prd_info: Product information from CRM system
    - silver.erp_px_cat_g1v2: Product category information from ERP
    
    Business Logic:
    - Surrogate key: ROW_NUMBER() ordered by product start date and product key
    - Only includes current products (prd_end_dt IS NULL)
================================================================================
*/

CREATE OR ALTER VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key_without_cat) AS product_key,  -- Surrogate key
    pn.prd_id AS product_id,
    pn.prd_key_without_cat AS product_number,
    pn.prd_nm AS product_name,
    pn.prd_cat_id AS category_id,
    pc.CAT AS category,
    pc.SUBCAT AS subcategory,
    pc.MAINTENANCE AS maintenance,
    pn.prd_line AS product_line,
    pn.prd_cost AS product_cost,
    pn.prd_start_dt AS product_start_date
FROM data_warehouse.silver.crm_prd_info AS pn
LEFT JOIN data_warehouse.silver.erp_px_cat_g1v2 AS pc
    ON pn.prd_cat_id = pc.ID
WHERE prd_end_dt IS NULL;                                                      -- Filter: current products only
