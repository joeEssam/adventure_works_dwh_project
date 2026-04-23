/*
================================================================================
    BRONZE LAYER - DATA DEFINITION SCRIPT
    Purpose: Create staging tables for raw data ingestion from source systems
    
    ⚠️  WARNING: This script will DROP and RECREATE all bronze layer tables.
         All existing data in these tables will be permanently deleted.
         Ensure backups are available before executing this script.
================================================================================
*/

USE data_warehouse;
SET NOCOUNT ON;  -- Suppress "rows affected" messages for cleaner output 

-- =============================================================================
-- CRM SOURCE TABLES
-- =============================================================================

-- Customer information from CRM system
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(30),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(10),
    cst_gndr            NVARCHAR(10),
    cst_create_date     DATE
);

-- Product information from CRM system
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info (
    prd_id      INT,
    prd_key     NVARCHAR(30),
    prd_nm      NVARCHAR(50),
    prd_cost    INT,
    prd_line    NVARCHAR(10),
    prd_start_dt DATE,
    prd_end_dt  DATE
);

-- Sales transaction details from CRM system
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num     NVARCHAR(30),
    sls_prd_key     NVARCHAR(30),
    sls_cust_id     INT,
    sls_order_dt    INT,
    sls_ship_dt     INT,
    sls_due_dt      INT,
    sls_sales       INT,
    sls_quantity    INT,
    sls_price       INT
);

-- =============================================================================
-- ERP SOURCE TABLES
-- =============================================================================

-- Customer data from ERP system (AZ12 extract)
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12 (
    CID     NVARCHAR(50),
    BDATE   DATE,
    GEN     NVARCHAR(20)
);

-- Location/geography data from ERP system (A101 extract)
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101 (
    CID     NVARCHAR(50),
    CNTRY   NVARCHAR(50)
);

-- Product category master from ERP system (PX_CAT_G1V2 extract)
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2 (
    ID          NVARCHAR(20),
    CAT         NVARCHAR(50),
    SUBCAT      NVARCHAR(50),
    MAINTENANCE NVARCHAR(10)
);

