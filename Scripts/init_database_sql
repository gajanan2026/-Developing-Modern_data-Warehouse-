/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

--- CHEAK DATABSE IS ALREADY EXIST OR NOT 
IF EXISTS (
    SELECT 1 
    FROM sys.databases 
    WHERE name = 'DataWarehouse'
)
BEGIN
    PRINT 'Database already exists';
END
GO

---- CREATE DATABASE ----
create database DataWarehouse 
GO
use dataWarehouse
GO

---   WE USE MEDALLION ARCHITECURE FOR CREATING DATA WAREHOUSE 

---  CREATING SCHEMAS --       [TO CHEAK SCHEMA GO TO SECURITY]
create  schema bronze;
Go
create schema silver;
Go
create schema gold ;
Go
