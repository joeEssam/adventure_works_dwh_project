# Adventure Works Data Warehouse Project

A professional data warehouse built using SQL Server and the Medallion Architecture (Bronze-Silver-Gold layers) to consolidate sales data from multiple enterprise systems.

## Project Objective

Develop a modern data warehouse that ingests, cleanses, and transforms raw data from ERP and CRM systems into business-ready analytics data, enabling informed decision-making and reporting.

## Architecture Overview

This project implements the **Medallion Architecture**, a three-layer approach that progressively refines data quality:

### 🥉 Bronze Layer
- **Purpose:** Raw data ingestion from source systems (ERP & CRM)
- **Tables:** `crm_*` and `erp_*` (exact source naming)
- **Load Strategy:** Full load, Truncate & Insert
- **Transformations:** None (raw data only)

### ⚪ Silver Layer  
- **Purpose:** Data cleansing and standardization
- **Tables:** Same naming as Bronze with quality improvements
- **Load Strategy:** Full load, Truncate & Insert
- **Transformations:** Data type standardization, null handling, deduplication, validation, enrichment

### 🟡 Gold Layer
- **Purpose:** Business-ready analytics data
- **Objects:** Views and aggregated tables (`dim_*`, `fact_*`, `agg_*`)
- **Load Strategy:** View-based (no data load)
- **Transformations:** Aggregations, integration, dimensional modeling, business logic

## Data Sources

| Source | Tables | Purpose |
|--------|--------|---------|
| **CRM** | `cust_info.csv`, `prd_info.csv`, `sales_details.csv` | Customer, product, and sales data |
| **ERP** | `CUST_AZ12.csv`, `LOC_A101.csv`, `PX_CAT_G1V2.csv` | Customer master, locations, and product categories |

## Project Structure

will be added here in the future, including directories for SQL scripts, documentation, datasets, and tests.

## Technical Stack

- **Database:** Microsoft SQL Server 2019+
- **Language:** T-SQL (Transact-SQL)
- **Source Format:** CSV files
- **Version Control:** Git
- **Documentation:** Markdown

## Naming Conventions Summary

- **Tables:** Use `snake_case` (all lowercase, underscores)
- **Bronze/Silver:** `<source_system>_<entity>` (e.g., `crm_customer_info`)
- **Gold:**  `<type>_<entity>` (e.g., `dim_customers`, `fact_sales`)
- **Keys:** `<table>_key` for surrogate keys
- **Technical Columns:** `dwh_<purpose>` (e.g., `dwh_load_date`, `dwh_source_system`)

See [naming_conventions.md](naming_conventions.md) for complete details.

## Key Features

✅ **Data Quality:** Systematic cleansing and validation  
✅ **Scalable Design:** Three-layer architecture supports future enhancements  
✅ **Documentation:** Clear naming conventions and technical documentation  
✅ **Version Control:** Git-tracked SQL scripts and documentation  
✅ **Analytics Ready:** Business-aligned dimensional models in Gold layer  

## Project Specifications

| Item | Details |
|------|---------|
| Data Sources | 2 systems (ERP, CRM) → 6 CSV tables |
| Scope | Current state (no historical tracking) |
| Load Type | Batch processing (daily/on-demand) |
| Data Quality | Cleanse before analytical use |
| Deliverables | Cleaned data + dimension/fact tables |

