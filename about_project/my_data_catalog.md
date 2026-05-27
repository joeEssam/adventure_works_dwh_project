# Data Catalog - Adventure Works Data Warehouse (Gold Layer)

## Overview
This catalog documents the tables and views in the Gold Layer of the Adventure Works Data Warehouse. The Gold Layer contains business-ready dimensional and fact tables designed for analytics and reporting.

---

## Fact Tables

### fact_sales
**Schema:** `gold`  
**Type:** Fact Table  
**Source:** Silver layer (crm_sales_details, crm_prd_info, crm_cust_info)  
**Purpose:** Central fact table capturing all sales transactions with associated product and customer dimensions.

| Column | Data Type | Description | Key Type |
|--------|-----------|-------------|----------|
| order_number | - | Unique identifier for each sales order | Business Key |
| product_key | Int | Reference to dim_products | Foreign Key |
| customer_key | Int | Reference to dim_customer | Foreign Key |
| order_date | DateTime | Date when the order was placed | - |
| ship_date | DateTime | Date when the order was shipped | - |
| due_date | DateTime | Expected delivery date | - |
| sales_amount | Decimal | Total sales value for the order line | Measure |
| quantity | Int | Number of units sold | Measure |
| price | Decimal | Unit price of the product | Measure |

**Relationships:**
- Links to `gold.dim_products` via `product_key`
- Links to `gold.dim_customer` via `customer_key`

---

## Dimension Tables

### dim_products
**Schema:** `gold`  
**Type:** Dimension Table  
**Source:** Silver layer (crm_prd_info, erp_px_cat_g1v2)  
**Purpose:** Product master data for categorization and analysis of sales by product attributes.

| Column | Data Type | Description | Key Type |
|--------|-----------|-------------|----------|
| product_key | Int | Unique identifier (surrogate key) | Primary Key |
| product_id | - | Original product identifier | Business Key |
| product_number | - | Product SKU/code | Business Key |
| product_name | - | Display name of the product | - |
| category_id | - | Category identifier | - |
| category | - | Primary product category | - |
| subcategory | - | Product subcategory classification | - |
| maintenance | - | Maintenance indicator | - |
| product_line | - | Product line classification | - |
| product_cost | Decimal | Standard cost of the product | - |
| product_start_date | DateTime | Date product became active | - |

**Key Characteristics:**
- Current records only (filtered: `prd_end_dt is null`)
- Surrogate key generated via ROW_NUMBER() ordered by start date and product key
- Combines CRM product info with ERP category information

---

### dim_customer
**Schema:** `gold`  
**Type:** Dimension Table  
**Source:** Silver layer (crm_cust_info, erp_cust_az12, erp_loc_a101)  
**Purpose:** Customer master data for analysis and segmentation of sales by customer attributes with the demographic and geographic information .

| Column | Data Type | Description | Key Type |
|--------|-----------|-------------|----------|
| customer_key | Int | Unique identifier (surrogate key) | Primary Key |
| customer_id | - | Original customer identifier from CRM | Business Key |
| customer_number | - | Customer account number | Business Key |
| first_name | - | Customer first name | - |
| last_name | - | Customer last name | - |
| country | - | Customer country of residence | - |
| marital_status | - | Customer marital status | - |
| gender | - | Customer gender (CRM is master source) | - |
| birthdate | Date | Customer date of birth | - |
| create_date | DateTime | Date customer was created in system | - |

**Key Characteristics:**
- Surrogate key generated via ROW_NUMBER() ordered by customer ID
- Gender logic: Uses CRM data as primary source, falls back to ERP if not available
- Integrated data from three sources (CRM master + two ERP tables)

---

## Data Relationships

```
fact_sales
├── product_key ──→ dim_products.product_key
└── customer_key ──→ dim_customer.customer_key
```

## Update Frequency
- **Gold Layer:** Refresh frequency determined by ETL schedule (see silver_data_load.sql)
- **Dimensions:** Updated when source data changes
- **Facts:** Loaded on each ETL run

---

## Data Quality Notes
- Product dimension filters out historical records (`prd_end_dt is null`)
- Left joins used in fact table allow for unmatched sales records
- Customer gender follows CRM hierarchy with ERP fallback logic
