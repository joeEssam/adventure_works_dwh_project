/*
================================================================================
    SILVER LAYER - DATA EXPLORATION SCRIPT
    Purpose: Validate and explore data in silver layer staging tables
    
    This script provides sample queries for initial data quality assessment
    and exploratory data analysis of silver layer tables.
================================================================================
*/

USE data_warehouse;
SET NOCOUNT ON;

-- =============================================================================
-- CRM CUSTOMER DATA EXPLORATION
-- =============================================================================

-- Retrieve sample of customer information from CRM staging table
SELECT TOP (1000)
    [cst_id]
    ,[cst_key]
    ,[cst_firstname]
    ,[cst_lastname]
    ,[cst_marital_status]
    ,[cst_gndr]
    ,[cst_create_date]
FROM [data_warehouse].[bronze].[crm_cust_info] ;

-- =============================================================================
-- CRM SALES DATA EXPLORATION
-- =============================================================================

-- Retrieve sample of sales transaction details from CRM staging table
SELECT TOP (1000)
    [sls_ord_num]
    ,[sls_prd_key]
    ,[sls_cust_id]
    ,[sls_order_dt]
    ,[sls_ship_dt]
    ,[sls_due_dt]
    ,[sls_sales]
    ,[sls_quantity]
    ,[sls_price]
FROM [data_warehouse].[bronze].[crm_sales_details] ;

-- =============================================================================
-- CRM PRODUCT DATA EXPLORATION
-- =============================================================================

-- Retrieve sample of product information from CRM staging table
SELECT TOP (1000)
    [prd_id]
    ,[prd_key]
    ,[prd_nm]
    ,[prd_cost]
    ,[prd_line]
    ,[prd_start_dt]
    ,[prd_end_dt]
FROM [data_warehouse].[bronze].[crm_prd_info] ;

-- =============================================================================
-- ERP CUSTOMER DATA EXPLORATION
-- =============================================================================

-- Retrieve sample of customer data from ERP AZ12 extract
SELECT TOP (1000)
    [CID]
    ,[BDATE]
    ,[GEN]
FROM [data_warehouse].[bronze].[erp_cust_az12] ;

-- =============================================================================
-- ERP LOCATION DATA EXPLORATION
-- =============================================================================

-- Retrieve sample of location/geography data from ERP A101 extract
SELECT TOP (1000)
    [CID]
    ,[CNTRY]
FROM [data_warehouse].[bronze].[erp_loc_a101] ;

-- =============================================================================
-- ERP PRODUCT CATEGORY DATA EXPLORATION
-- =============================================================================

-- Retrieve sample of product category master from ERP PX_CAT_G1V2 extract
SELECT TOP (1000)
    [ID]
    ,[CAT]
    ,[SUBCAT]
    ,[MAINTENANCE]
FROM [data_warehouse].[bronze].[erp_px_cat_g1v2] ;