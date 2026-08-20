/* 
============================================================================================
DDL Script: create silver tables
============================================================================================
Script purpose:
this script creates tables in the 'silver' schema, dropping existing tables if they already exist.
Run this script to redefine the DDL structure of 'bronze' tables
==============================================================================================
*/

IF OBJECT_ID ('silver_crm_cust_info') IS NOT NULL
	DROP TABLE silver_crm_cust_info;
CREATE TABLE silver_crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver_crm_prd_info') IS NOT NULL
	DROP TABLE silver_crm_prd_info;
CREATE TABLE silver_crm_prd_info(
	prd_id INT,
	cat_id NVARCHAR(40),
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost NVARCHAR(50),
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver_crm_sales_details') IS NOT NULL
	DROP TABLE silver_crm_sales_details;
CREATE TABLE silver_crm_sales_details(
	sls_order_num NVARCHAR (40),
	sls_prd_key  NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);


IF OBJECT_ID ('silver_erp_PX_CAT_G1V2') IS NOT NULL
	DROP TABLE silver_erp_PX_CAT_G1V2;
CREATE TABLE silver_erp_PX_CAT_G1V2(
    ID  NVARCHAR(20),
	CAT NVARCHAR(20),
	SUBCAT NVARCHAR(30),
	MAINTENANCE NVARCHAR(10),
	dwh_create_date DATETIME2 DEFAULT GETDATE()

);


IF OBJECT_ID ('silver_erp_LOC_A101') IS NOT NULL
	DROP TABLE silver_erp_LOC_A101;
CREATE TABLE silver_erp_LOC_A101(
	CID NVARCHAR(30),
	CNTRY NVARCHAR(20),
	dwh_create_date DATETIME2 DEFAULT GETDATE()

);


IF OBJECT_ID ('silver_erp_CUST_AZ12') IS NOT NULL
	DROP TABLE silver_erp_CUST_AZ12;
CREATE TABLE silver_erp_CUST_AZ12(
    CID  NVARCHAR(50),
	BDATE DATE,
	GEN VARCHAR(10),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

