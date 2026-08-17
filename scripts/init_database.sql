/*
====================================================================
Create Database and Schemas
====================================================================
Script purpose:
      This script creates new Database named 'DataWarehouse' after checking if it already exists.
      if the database already exists , it is dropped and recreated . Additionally , the script sets up three schemas 
      within the database: 'bronze' , 'silver' and 'gold'.
*/

USE master;
GO
-- Create the 'DataWarehouse' Database
CREATE DATABASE DataWarehouse;
GO
USE DataWarehouse;
GO
  
--Create Schemas
CREATE SCHEMA Bronze;
GO
  
CREATE SCHEMA silver;
GO
  
CREATE SCHEMA gold;
GO
    
