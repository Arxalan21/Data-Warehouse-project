/*
======================================================================================================
DDL Script : create bronze tables
======================================================================================================
Script purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables if they already exist.
    Run this script to re-define the DDL structure of 'bronze' tables
=======================================================================================================
*/



IF OBJECT_ID ('bronze_crm_cust_info') IS NOT NULL
	DROP TABLE bronze_crm_cust_info;

GO

CREATE TABLE bronze_crm_cust_info(
	cst_id                INT,
	cst_key               NVARCHAR(50),
	cst_firstname         NVARCHAR(50),
	cst_lastname          NVARCHAR(50),
	cst_marital_status    NVARCHAR(50),
	cst_gndr              NVARCHAR(50),
	cst_create_date       DATE
);
GO 

IF OBJECT_ID ('bronze_crm_prd_info') IS NOT NULL
	DROP TABLE bronze_crm_prd_info;
GO

CREATE TABLE bronze_crm_prd_info(
	prd_id                INT,
	prd_key               NVARCHAR(50),
	prd_nm                NVARCHAR(50),
	prd_cost              NVARCHAR(50),
	prd_line              NVARCHAR(50),
	prd_start_dt          DATE,
	prd_end_date          DATE

);
GO 

IF OBJECT_ID ('bronze_crm_sales_details') IS NOT NULL
	DROP TABLE bronze_crm_sales_details;
GO

CREATE TABLE bronze_crm_sales_details(
	sls_order_num         INT,
	sls_prd_key           NVARCHAR(50),
	sls_cust_id           INT,
	sls_order_dt          INT,
	sls_ship_dt           INT,
	sls_due_dt            INT,
	sls_sales             INT,
	sls_quantity          INT,
	sls_price             INT

);
GO

IF OBJECT_ID ('bronze_erp_PX_CAT_G1V2') IS NOT NULL
	DROP TABLE bronze_erp_PX_CAT_G1V2;
GO

CREATE TABLE bronze_erp_CUST_AZ12(
	CID                  NVARCHAR(50),
	BDATE                DATE,
	GEN                  VARCHAR(10)
);
GO

IF OBJECT_ID ('bronze_erp_LOC_A101') IS NOT NULL
	DROP TABLE bronze_erp_LOC_A101;
GO

CREATE TABLE bronze_erp_LOC_A101(
	CID                 NVARCHAR(30),
	CNTRY               NVARCHAR(20)
);
GO

IF OBJECT_ID ('bronze_erp_PX_CAT_G1V2') IS NOT NULL
	DROP TABLE bronze_erp_PX_CAT_G1V2;
GO

CREATE TABLE bronze_erp_PX_CAT_G1V2(
	ID                 NVARCHAR(20),
	CAT                NVARCHAR(20),
	SUBCAT             NVARCHAR(30),
	MAINTENANCE        NVARCHAR(10)
);
