  ---  USE BULK INSET METHOD WITH TRUNCATE  
  --- WE MADE STORED PROCEDURE
  --- USE OF TRY BLOCK AND CATCH BLOCK  [ERROR_MESSAGE(),EROOR_LINE()]
  --  USE OF TRANSACTION  (COMMIT,ROLLBACK,@@TRANCOUNT)



CREATE OR ALTER PROCEDURE  BRONZE.LOAD_BRONZE AS     /* CREATE OR ALTER USE INSTERD OF CREATE ONLY BECAUSE IF SP IS ALREADY EXIST THEN ALTER IF NOT EXIST THEN CREATE */
BEGIN    
BEGIN TRY 
    BEGIN TRANSACTION 
    ------------------------------------- ----------------------  1 TABLE  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
     DECLARE @Start1 DATETIME2 = SYSDATETIME()
    TRUNCATE TABLE [bronze].[crm_cust_info]      ---IMP 
    BULK INSERT [bronze].[crm_cust_info]
    FROM 'D:\Bara project dataset\DAta_Warehouse_Project_zip\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR  = ',',
        TABLOCK
    )
    DECLARE @End1 DATETIME2 = SYSDATETIME()
    select
    DATEDIFF(MILLISECOND,@Start1,@End1) as load_time_t1

   ----------------------------------------------------- 2 TABLE -----------------------------------------------------------------------
    declare @start2 datetime2 = sysdatetime()
    TRUNCATE TABLE [bronze].[crm_prd_info]
    BULK INSERT [bronze].[crm_prd_info]
    FROM 'D:\Bara project dataset\DAta_Warehouse_Project_zip\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
    WITH (
        FIRSTROW = 2 ,
        FIELDTERMINATOR = ',' ,
        TABLOCK
    )
    declare @end2 datetime2 = sysdatetime()
    select 
        DATEDIFF(MILLISECOND,@start2,@end2) as load_time_t2
    ---------------------  3 TABLE  -------------------------------------------------------------------
    declare @start3 datetime2 = sysdatetime()
    TRUNCATE TABLE [bronze].[crm_sales_details]
    BULK INSERT [bronze].[crm_sales_details] 
    FROM 'D:\Bara project dataset\DAta_Warehouse_Project_zip\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR  = ',',
        TABLOCK   
    )
    declare @end3 datetime2 = sysdatetime()
    select
        DATEDIFF(MILLISECOND,@start3,@end3)load_time_t3
    ---------------------  4 TABLE  ------------------------------------------------------------------------
    declare @start4 datetime2 = sysdatetime()
    TRUNCATE TABLE [bronze].[erp_cust_az12]
    BULK INSERT [bronze].[erp_cust_az12]
    FROM 'D:\Bara project dataset\CUST_AZ12.csv'
    WITH(
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    )
   declare @end4 datetime2 = sysdatetime()
    select
        DATEDIFF(MILLISECOND,@start4,@end4)load_time_t4
    ---------------------  5TABLE  ------------------------------------------------------------------------
     declare @start5 datetime2 = sysdatetime()
    TRUNCATE TABLE [bronze].[erp_loc_a101]
    BULK INSERT [bronze].[erp_loc_a101]
    FROM 'D:\Bara project dataset\LOC_A101.csv'
    WITH(
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
        )
   declare @end5 datetime2 = sysdatetime()
    select
        DATEDIFF(MILLISECOND,@start5,@end5)load_time_t5
    ---------------------  6TABLE  -------------------------------------------------------------------------------
    declare @start6 datetime2 = sysdatetime()
    TRUNCATE TABLE [bronze].[erp_px_cat_g1v2]
    BULK INSERT [bronze].[erp_px_cat_g1v2]
    FROM 'D:\Bara project dataset\PX_CAT_G1V2.csv'
    WITH(
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
        )
        declare @end6 datetime2 = sysdatetime()
           select
        DATEDIFF(MILLISECOND,@start6,@end6)load_time_t6
  COMMIT 
END TRY 
BEGIN CATCH 
    IF @@TRANCOUNT > 0
    ROLLBACK
    SELECT
            ERROR_MESSAGE() AS Msg,
            ERROR_LINE() AS Line
END CATCH
END 

--------------------------------------------------------------------------------------------------------------------
EXEC  BRONZE.LOAD_BRONZE    -- EXECUATION OF STORED PROCEDURE 
---------------------------------------------------------------------------------------------------------------------

