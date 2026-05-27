/*
================================================================================
    SILVER LAYER - DATA DEFINITION SCRIPT
    Purpose: Create staging tables for cleansed and transformed data
    
    ⚠️  WARNING: This script will DROP and RECREATE all silver layer tables.
            All existing data in these tables will be permanently deleted.
            Ensure backups are available before executing this script.
================================================================================
*/

USE data_warehouse;
SET NOCOUNT ON;  -- Suppress "rows affected" messages for cleaner output

-- =============================================================================
-- CRM SOURCE TABLES
-- =============================================================================

-- CRM Customer information staging table
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;

CREATE TABLE silver.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(30),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(10),
    cst_gndr            NVARCHAR(10),
    cst_create_date     DATETIME2,
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);

-- CRM Product information staging table
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info (
    prd_id              INT,
    prd_cat_id          NVARCHAR(10),
    prd_key             NVARCHAR(30),
    prd_key_without_cat NVARCHAR(30),
    prd_nm              NVARCHAR(50),
    prd_cost            INT,
    prd_line            NVARCHAR(30),
    prd_start_dt        DATE,
    prd_end_dt          DATE,
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);

-- CRM Sales transaction details staging table
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details (
    sls_ord_num         NVARCHAR(30),
    sls_prd_key         NVARCHAR(30),
    sls_cust_id         INT,
    sls_order_dt        DATE,
    sls_ship_dt         DATE,
    sls_due_dt          DATE,
    sls_sales           INT,
    sls_quantity        INT,
    sls_price           INT,
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);

-- =============================================================================
-- ERP SOURCE TABLES
-- =============================================================================

-- ERP Customer data staging table (AZ12 extract)
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;

CREATE TABLE silver.erp_cust_az12 (
    CID                 NVARCHAR(50),
    BDATE               DATE,
    GEN                 NVARCHAR(20),
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);

-- ERP Location/geography data staging table (A101 extract)
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;

CREATE TABLE silver.erp_loc_a101 (
    CID                 NVARCHAR(50),
    CNTRY               NVARCHAR(50),
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);

-- ERP Product category master staging table (PX_CAT_G1V2 extract)
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;

CREATE TABLE silver.erp_px_cat_g1v2 (
    ID                  NVARCHAR(20),
    CAT                 NVARCHAR(50),
    SUBCAT              NVARCHAR(50),
    MAINTENANCE         NVARCHAR(10),
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);

