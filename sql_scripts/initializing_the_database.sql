/*
================================================================================
    FILE: initializing_the_database.sql
    PURPOSE: Initialize the Adventure Works Data Warehouse database and schemas
    
    DESCRIPTION:
    This script sets up the foundational database structure for the data warehouse
    by creating the main database and three layer schemas (bronze, silver, gold).
    
    EXECUTION FLOW:
    1. Checks if data_warehouse database exists
    2. If exists: Drops the database (CAUTION - see warning below)
    3. Creates a fresh data_warehouse database
    4. Creates three schemas: bronze, silver, and gold
    
    ⚠️  WARNING - DATA LOSS RISK:
    ================================================================================
    Running this script will DROP the data_warehouse database if it exists.
    ALL DATA in the database will be permanently deleted.
    
    Do NOT run this script in PRODUCTION environments without backup.
    Ensure you have backups before executing, especially if the database
    contains important data.
================================================================================
*/

USE master;

-- Drop and recreate database if it exists
IF EXISTS (
    SELECT 1 
    FROM sys.databases 
    WHERE name = 'data_warehouse'
)
BEGIN
    ALTER DATABASE data_warehouse 
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    
    DROP DATABASE data_warehouse;
END

GO

CREATE DATABASE data_warehouse;

GO

USE data_warehouse;

GO

-- Create layer schemas
CREATE SCHEMA bronze;

GO

CREATE SCHEMA silver;

GO

CREATE SCHEMA gold;

GO
