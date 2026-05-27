
/*
================================================================================
    GOLD LAYER - FACT SALES VIEW
    Purpose: Central fact table for sales transactions with product and customer
             dimensions for analytics and reporting
    
    Source Tables:
    - silver.crm_sales_details: Sales order line details
    - gold.dim_products: Product dimension table
    - gold.dim_customer: Customer dimension table
================================================================================
*/

CREATE OR ALTER VIEW gold.fact_sales AS
SELECT 
    sd.sls_ord_num AS order_number,
    pr.product_key,
    cr.customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS ship_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pr 
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customer AS cr 
    ON sd.sls_cust_id = cr.customer_id;
