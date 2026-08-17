/*
====================================================================================
Stored procedure: Load Bronze Layer (source -> Bronze)
====================================================================================
Script purpose:
  This stored procedure loads data into the 'bronze' schema from external CSV files.
  It performs the following actions:
  - Truncates the bronze tables before loading data,
  - Uses the 'BULK INSERT' command to load data from csv Files to bronze tables.
  

Parameters:
   None,
   this stored procedure procedure does not accept any parameters or return any values.


Usage example:
     EXEC bronze.load_bronze;
======================================================================================
*/



CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
     DECLARE @batch_start_time DATETIME ,@batch_end_time DATETIME;
    BEGIN TRY
        PRINT '================================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '================================================================';

        PRINT '----------------------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '----------------------------------------------------------------';

        PRINT '>> Truncating Table : bronze_crm_cust_info';
        TRUNCATE TABLE bronze_crm_cust_info;

        PRINT ' Inserting into : bronze_crm_cust_info';
        BULK INSERT bronze_crm_cust_info
        FROM 'C:\Raw data\source_crm\cust_info.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        PRINT '>> Truncating Table : bronze_crm_prd_info';
        TRUNCATE TABLE bronze_crm_prd_info;

        PRINT ' Inserting into : bronze_crm_prd_info';
        BULK INSERT bronze_crm_prd_info
        FROM 'C:\Raw data\source_crm\prd_info.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        PRINT '>> Truncating Table : bronze_crm_sales_details';
        TRUNCATE TABLE bronze_crm_sales_details;

        PRINT ' Inserting into : bronze_crm_sales_details';
        BULK INSERT bronze_crm_sales_details
        FROM 'C:\Raw data\source_crm\sales_details.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        PRINT '----------------------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '----------------------------------------------------------------';

        PRINT '>> Truncating Table :  bronze_erp_CUST_AZ12';
        TRUNCATE TABLE bronze_erp_CUST_AZ12;

        PRINT ' Inserting into : bronze_erp_CUST_AZ12 ';
        BULK INSERT bronze_erp_CUST_AZ12
        FROM 'C:\Raw data\source_crm\CUST_AZ12.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        PRINT 'Truncating Table :  bronze_erp_LOC_A101';
        TRUNCATE TABLE bronze_erp_LOC_A101;

        PRINT ' Inserting into : bronze_erp_LOC_A101';
        BULK INSERT bronze_erp_LOC_A101
        FROM 'C:\Raw data\source_crm\LOC_A101.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        PRINT 'Truncating Table :  bronze_erp_PX_CAT_G1V2';
        TRUNCATE TABLE bronze_erp_PX_CAT_G1V2;

        PRINT ' Inserting into : bronze_erp_PX_CAT_G1V2';
        BULK INSERT bronze_erp_PX_CAT_G1V2
        FROM 'C:\Raw data\source_crm\PX_CAT_G1V2.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
    
         SET @batch_end_time = GETDATE();
         PRINT '==============================================================================================='
         PRINT 'Loading bronze layer is completed';
         PRINT '   - Total loading duration : ' + CAST(DATEDIFF(SECOND,@batch_start_time , @batch_end_time) AS NVARCHAR) + 'seconds';
         PRINT '==============================================================================================='

    END TRY
    BEGIN CATCH 
        PRINT '===============================================================================';
        PRINT ' ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT ' Error Message + ERROR_MESSAGE()';
        PRINT '==============================================================================='
    END CATCH
END
