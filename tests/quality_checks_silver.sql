/*
================================================================================
Quality Checks
================================================================================
Script purpose:
    This script performs various quality checks for data consistency, accuracy , 
    and standardization accross the 'silver' schema . it includes checks for:
    - Null or duplicate primary keys
    - unwanted spaces in string fields
    - Data standardization and consistency
    - Invalid date ranges and orders
    - Data consistency between related fields
Usage notes:
    - Run these checks after loading silver layer
    - investigate and resolve any discrepancies found during the checks 
================================================================================
*/

-- =============================================================================
--CHECKING silver_crm_cust_info
--==============================================================================

--CHECK for nulls or duplicates in primary key
-- expectation : no result

SELECT 
prd_id,
COUNT(*)
FROM silver_crm_prd_info  
GROUP BY prd_id
HAVING COUNT(*) > 1
 

 -- ========================================================================
 -- Checking silver_crm_prd_info
 --=========================================================================
-- check for unwanted spaces
--EXPECTATION : NO RESULT
SELECT 
prd_nm
FROM silver_crm_prd_info
WHERE prd_nm != TRIM(prd_nm)   --TRIM() Removes leading & trailing spaces from a string

--DATA standardization and consistency
SELECT DISTINCT prd_line
FROM silver_crm_prd_info;

SELECT DISTINCT cst_marital_status
FROM silver_crm_cust_info;

-- check for invalid date orders
SELECT * FROM silver_crm_prd_info
WHERE prd_end_date < prd_start_dt

SELECT * FROM silver_crm_prd_info;

--=============================================================================================
-- CHECKING: silver_crm_sales_details
--=============================================================================================

-- check for invalid dates order dt
SELECT 
NULLIF(sls_order_dt , 0) sls_order_dt
FROM silver_crm_sales_details
WHERE sls_order_dt <=0 
OR LEN(sls_order_dt) != 8
OR sls_order_dt > 38473
OR sls_order_dt < 384875;

-- shipping date
SELECT 
NULLIF(sls_ship_dt , 0) sls_ship_dt
FROM silver_crm_sales_details
WHERE sls_ship_dt <= 0 
OR LEN(sls_ship_dt) != 8
OR sls_ship_dt > 38473
OR sls_ship_dt < 384875

-- due date
SELECT 
NULLIF(sls_due_dt , 0) sls_due_dt
FROM silver_crm_sales_details
WHERE sls_due_dt <= 0 
OR LEN(sls_due_dt) != 8
OR sls_due_dt > 38473
OR sls_due_dt < 384875

-- check for invalid date orders
SELECT * FROM silver_crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

--CHECK data consistency : between sales, quantity and price
-- >> sales = quantity * price
-- >> values must not be null , zero or negative

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price 
FROM 
silver_crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales , sls_quantity, sls_price

SELECT * FROM silver_crm_sales_details

--============================================================================================================
-- 
-- identify out of range dates
SELECT DISTINCT 
BDATE
FROM silver_erp_CUST_AZ12
WHERE BDATE < '1926-01-01' OR BDATE > GETDATE()

-- DATA standardization and consistency
SELECT DISTINCT
GEN
FROM silver_erp_CUST_AZ12

--===========================================================================
-- checking: silver_ERP_LOC_A101
-- DATA standardization and consistency
SELECT DISTINCT
CNTRY
FROM silver_erp_LOC_A101
ORDER BY CNTRY

--=============================================================================
--check for unwanted spaces
SELECT * FROM silver_erp_PX_CAT_G1V2
WHERE CAT != TRIM(CAT)

-- DAta standardization & consistency
SELECT DISTINCT 
CAT
FROM silver_erp_PX_CAT_G1V2

