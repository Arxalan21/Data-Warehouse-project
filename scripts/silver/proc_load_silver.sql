/*
=======================================================================================================
Stored procedure : Load silver layer (Bronze -> silver)
========================================================================================================
SCRIPT PURPOSE:
      This stored procedure performs the ETL(Extract , transform , load) process to populate the 'silver' 
      schema tables from the 'bronze' schema.
ACTIONS PERFORMED:
      - Truncates silver tables
      - Inserts transformed and cleansed data from Bronze into Silver tables.

PARAMETERS:
      None.
      This stored procedure does not accept any parameters or return any values.

Usage example:
      EXEC Silver.load_silver;
=========================================================================================================
*/
CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN
    DECLARE @start_time DATETIME , @end_time DATETIME , @batch_start_time DATETIME , @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '=======================================================================';
        PRINT 'Loading silver Layer';
        PRINT '=======================================================================';

        PRINT '-----------------------------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '-----------------------------------------------------------------------';

        --loading silver_crm_cust_info
        SET @start_time = GETDATE();
        PRINT '>> Truncating table : silver_crm_cust_info';
        TRUNCATE TABLE silver_crm_cust_info;
        PRINT '>> INSerting data into: silver_crm_cust_info'
        INSERT INTO silver_crm_cust_info(
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )


            SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) as cst_firstname,
            TRIM(cst_lastname) as cst_lastname,
            CASE 
                 WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                 ELSE 'n/a'
            END cst_marital_status, -- normalize marital status values to readable format

            CASE 
                 WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                 ELSE 'n/a'
            END cst_gndr, -- normalize gender values to readable format
            cst_create_date
            FROM(

                SELECT 
                    *,
                  ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS Flag_Last
                FROM bronze_crm_cust_info
                WHERE cst_id IS NOT NULL
        )T 
        WHERE Flag_Last = 1 ; -- SELECT the most recent record per customer
        SET @end_time =GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time , @end_time) AS NVARCHAR) + 'seconds'
        PRINT '>> ----------------------' ;

        -- Loading silver_crm_prd_info
        SET @start_time = GETDATE();
        PRINT '>> Truncating table : silver_crm_prd_info';
        TRUNCATE TABLE silver_crm_prd_info;
        PRINT '>> INSerting data into: silver_crm_prd_info'


        INSERT INTO dbo.silver_crm_prd_info(
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_date
        )

        SELECT 
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1 , 5), '-' , '_') AS cat_id,  -- extract category id
            SUBSTRING(prd_key, 7 , LEN(prd_key)) prd_key,  -- extract product key
            prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost,
            CASE UPPER(TRIM(prd_line))  
                 WHEN 'M' THEN 'Mountain'
                 WHEN 'R' THEN 'Road'
                 WHEN 'S' THEN 'Other sales'
                 WHEN 'T' THEN 'Touring'
                 ELSE 'n/a'
            END AS prd_line,  -- map product line codes to descriptive values

            prd_start_dt,

            DATEADD(DAY, -1,
            LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)
             )AS prd_end_date  -- calculate end date as one day before the next start date
         FROM dbo.bronze_crm_prd_info;
         SET @end_time =GETDATE();
         PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time , @end_time) AS NVARCHAR) + 'seconds'
         PRINT '>> ----------------------' ;


        -- LOading crm_sales_details
        SET @start_time = GETDATE();
        PRINT '>> Truncating table : silver_crm_sales_details';
        TRUNCATE TABLE silver_crm_sales_details;
        PRINT '>> INSerting data into: silver_crm_sales_details'


        INSERT INTO silver_crm_sales_details(
	        sls_order_num,
	        sls_prd_key,
	        sls_cust_id,
	        sls_order_dt,
	        sls_ship_dt,
	        sls_due_dt,
	        sls_sales,
	        sls_quantity,
	        sls_price
	        )

        SELECT
	        sls_order_num,
	        sls_prd_key,
	        sls_cust_id,
	        CASE 
		        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
		        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	        END AS sls_order_dt,

	        CASE 
		        WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	        END AS sls_ship_dt,


	        CASE 
		        WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
		        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	        END AS sls_due_dt,

	        CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
		         THEN sls_quantity * ABS(sls_price)
	          ELSE sls_sales
	        END sls_sales, -- recalculate sales if original value is missing or incorrect

	        sls_quantity,


	        CASE WHEN sls_price IS NULL OR sls_price <=0
		         THEN sls_sales / NULLIF(sls_quantity,0)
	          ELSE sls_price
	        END sls_price  -- derive price if original value is invalid

        FROM bronze_crm_sales_details;
        SET @end_time =GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time , @end_time) AS NVARCHAR) + 'seconds'
        PRINT '>> ----------------------' ;


        PRINT '----------------------------------------------------------------------';
        PRINT 'Loading ERP Tables'
        PRINT '----------------------------------------------------------------------';

        -- Loading : erp_CUST_AZ12
        SET @start_time = GETDATE()
        PRINT '>> Truncating table : silver_erp_CUST_AZ12';
        TRUNCATE TABLE silver_erp_CUST_AZ12;
        PRINT '>> INSerting data into: silver_erp_CUST_AZ12'


        INSERT INTO silver_erp_CUST_AZ12(
            CID,
            BDATE,
            GEN
        )
        SELECT
            CASE 
                WHEN CID LIKE 'NAS%' 
                THEN SUBSTRING(CID , 4 , LEN(CID))  -- removed 'NAS' Prefix if present
                ELSE CID
            END CID,

            CASE 
               WHEN BDATE > GETDATE() THEN NULL
               ELSE BDATE
            END as BDATE, -- set future birthdates to null

            CASE
                WHEN UPPER(TRIM(GEN)) IN ('F' , 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(GEN)) IN ('M' , 'MALE') THEN 'Male'
                ELSE 'n/a'
            END AS GEN   -- normalize gender values and handle unknown cases
        FROM bronze_erp_CUST_AZ12;
        SET @end_time =GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time , @end_time) AS NVARCHAR) + 'seconds'
        PRINT '>> ----------------------' ;


        -- Loading erp_LOC_A101
        SET @start_time = GETDATE()
        PRINT '>> Truncating table : silver_erp_LOC_A101';
        TRUNCATE TABLE silver_erp_LOC_A101;
        PRINT '>> INSerting data into: silver_erp_LOC_A101'


        INSERT INTO silver_erp_LOC_A101(
           CID,
           CNTRY
        )
        SELECT 
            REPLACE(CID, '-' , '') CID,
            CASE 
                WHEN TRIM(CNTRY) = 'DE' THEN 'GERMANY'
                WHEN TRIM(CNTRY) IN ('US' , 'USA') THEN 'United states'
                WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'n/a'
                ELSE TRIM(CNTRY)
            END AS CNTRY    -- normalize and handle missing or blanl country codes
        FROM bronze_erp_LOC_A101;
        SET @end_time =GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time , @end_time) AS NVARCHAR) + 'seconds'
        PRINT '>> ----------------------' ;


        -- Loading erp_PX_CAT_G1V2
        SET @start_time = GETDATE()
        PRINT '>> Truncating table : silver_erp_PX_CAT_G1V2';
        TRUNCATE TABLE silver_erp_PX_CAT_G1V2;
        PRINT '>> INSerting data into: silver_erp_PX_CAT_G1V2'


        INSERT INTO silver_erp_PX_CAT_G1V2(
	        ID,
	        CAT,
	        SUBCAT,
	        MAINTENANCE
        )


        SELECT
	        ID,
	        CAT,
	        SUBCAT,
	        MAINTENANCE
        FROM bronze_erp_PX_CAT_G1V2;
        SET @end_time =GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time , @end_time) AS NVARCHAR) + 'seconds'
        PRINT '>> ----------------------' ;

        SET @batch_end_time = GETDATE();
        PRINT '========================================================================'
        PRINT 'Loading silver layer is completed';
        PRINT '   - Total load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time , @batch_end_time) AS NVARCHAR) + 'seconds'
            PRINT '========================================================================'
    END TRY
    BEGIN CATCH 
        PRINT '===============================================================================';
        PRINT ' ERROR OCCURED DURING LOADING SILVER LAYER';
        PRINT ' Error Message' + ERROR_MESSAGE();
        PRINT '==============================================================================='
    END CATCH
END







