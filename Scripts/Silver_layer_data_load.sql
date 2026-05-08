



CREATE  OR ALTER PROCEDURE SILVER.SILVER_LOAD  AS       --- PROCEDURE START 
BEGIN 
BEGIN TRY 
 SET XACT_ABORT ON;
 BEGIN TRANSACTION
------------------------------------------ [silver].[crm_cust_info]Data Transformation And Loading  -------------------------------------------------------------
DECLARE @START1 DATETIME2 = SYSDATETIME()
TRUNCATE TABLE [silver].[crm_cust_info];
insert into [silver].[crm_cust_info]
 (  [cst_id],
    [cst_key],
    [cst_firstname],
    [cst_lastname],
    [cst_marital_status],
    [cst_gndr],
    [cst_create_date] )

SELECT 
      [cst_id],
      [cst_key],
      upper(TRIM([cst_firstname])) AS [cst_firstname] ,
      upper( TRIM([cst_lastname])) AS [cst_lastname],
   CASE 
        WHEN upper([cst_marital_status]) = 'M' THEN 'Married'
        WHEN upper([cst_marital_status]) = 'S' THEN 'Single'
        else 'n/a'
   end as [cst_marital_status],
   CASE 
        WHEN upper([cst_gndr]) = 'M' THEN 'Male'
        WHEN upper([cst_gndr]) = 'F' THEN 'Female'
        else 'n/a'
   end as [cst_gndr],
      [cst_create_date]    
from (
    SELECT * 
	    FROM (
    SELECT *,
	    ROW_NUMBER()OVER(PARTITION BY[cst_id] ORDER BY [cst_create_date] desc) AS  lAST_FLAG
	    FROM [bronze].[crm_cust_info])T 
	    WHERE lAST_FLAG = 1  )tt 
DECLARE @END1 datetime2 = sysdatetime()
select DATEDIFF(MILLISECOND,@start1 ,@end1) as load_time_t1
  
------------------------------------------------ [silver].[crm_prd_info] Data Transformation And Loading   -----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @START2 DATETIME2 = SYSDATETIME()
TRUNCATE TABLE [silver].[crm_prd_info];
insert into [silver].[crm_prd_info] 
(
prd_id ,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
           )
select 
	[prd_id],
	REPLACE(SUBSTRING(prd_key,1,5) ,'-','_') as cat_id,
	SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key ,
	[prd_nm],
	isnull([prd_cost],0) as [prd_cost],
case  
	when UPPER(TRIM( [prd_line])) = 'M' THEN 'Mountain'
	WHEN UPPER(TRIM( [prd_line])) = 'R'  THEN 'Road'
	WHEN UPPER(TRIM( [prd_line]))= 'S'  THEN 'Other sales'
	WHEN UPPER(TRIM( [prd_line]))= 'T'  THEN 'Touring'
	ELSE 'NA'
END AS[prd_line],
	  CAST([prd_start_dt]AS date) AS [prd_start_dt] ,
	  CAST(LEAD([prd_start_dt]) OVER(PARTITION BY [prd_key] ORDER BY [prd_start_dt]) -1  AS DATE) AS [prd_end_dt]
from bronze.crm_prd_info
DECLARE @END2 DATETIME =SYSDATETIME()
SELECT DATEDIFF(MILLISECOND,@START2,@END2) AS LOAD_TIME_T2
-------------------------------------------------------------- [silver].[crm_sales_details]] Data Transformation And Loading  ---------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* SOME CHANGES NEEDED  
    sls_order_dt DATE,
    sls_ship_dt  DATE,
    sls_due_dt   DATE,  WE CHANE DATATYPE IN THIS SCHEMA FROM INT TO NUMBER */
    
-------------------------------------------------------------------------
DECLARE @START3 DATETIME2 = SYSDATETIME()
TRUNCATE TABLE [silver].[crm_sales_details];  
INSERT INTO  [silver].[crm_sales_details]     
(
    sls_ord_num , 
    sls_prd_key , 
    sls_cust_id ,
    sls_order_dt,       
    sls_ship_dt ,      
    sls_due_dt  ,      
    sls_sales  ,  
    sls_quantity, 
    sls_price 
   
)
select 
	[sls_ord_num],
	[sls_prd_key],
	[sls_cust_id],
CASE 
	WHEN [sls_order_dt] =0 OR  LEN([sls_order_dt]) !=8 THEN NULL
	ELSE  CAST( CAST([sls_order_dt] AS VARCHAR) AS DATE) 
	END AS [sls_order_dt] ,
CASE 
	WHEN [sls_ship_dt] =0 OR  LEN([sls_ship_dt]) != 8 THEN NULL
	ELSE  CAST( CAST([sls_ship_dt] AS VARCHAR) AS DATE) 
	END AS [sls_ship_dt],
CASE 
	WHEN [sls_due_dt] = 0 OR  LEN([sls_due_dt]) != 8 THEN NULL
	ELSE  CAST( CAST([sls_due_dt] AS VARCHAR) AS DATE) 
	END AS [sls_due_dt]  ,
CASE 
	WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
	THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
	END AS sls_sales, -- Recalculate sales if original value is missing or incorrect
	sls_quantity,
CASE 
	WHEN sls_price IS NULL OR sls_price <= 0 
	THEN sls_sales / NULLIF(sls_quantity, 0)
	ELSE sls_price  -- Derive price if original value is invalid
END AS sls_price

from [bronze].[crm_sales_details]
DECLARE @END3 DATETIME2 = SYSDATETIME()
SELECT DATEDIFF(MILLISECOND,@START3,@END3) AS LOAD_TIME_T3

------------------------------------------------------------------------------    [silver].[erp_cust_az12]] Data Transformation And Loading  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @START4 DATETIME2 = SYSDATETIME ()
TRUNCATE TABLE [silver].[erp_cust_az12] ;
insert into [silver].[erp_cust_az12] 
( [cid],
  [bdate],
  [gen] 
)
select 
 case 
    when cid like 'nas%' then SUBSTRING(cid,4,len(cid))
    else cid
end as cid,
case 
    when bdate > GETDATE() then null
    else bdate
end as bdate,
    CASE 
    WHEN GEN = 'F' THEN  trim('Female')
    WHEN GEN = 'M' THEN  trim('Male')
    WHEN GEN = ' ' THEN NULL
    WHEN GEN = 'Male' THEN  TRIM(GEN)
    WHEN GEN = 'Female' THEN TRIM(GEN)
    ELSE GEN
END  as gen   
from [bronze].[erp_cust_az12] 
DECLARE @END4 DATETIME2 = SYSDATETIME ()
SELECT 
    DATEDIFF(MILLISECOND,@START4,@END4) AS LOAD_TIME_T4
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------[silver].[erp_loc_a101]--------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @START5 DATETIME2 = SYSDATETIME()
TRUNCATE TABLE [silver].[erp_loc_a101]
insert into [silver].[erp_loc_a101]
  ( [cid],
    [cntry]  )
select   
 REPLACE(cid,'-','') as cid ,
case
    when cntry is null  then 'n/a'
    when cntry = '' then 'n/a'
    when cntry in ('us','usa') then 'United States'
    when cntry = 'de' then 'Germany' 
    else cntry
end as cntry
from [bronze].erp_loc_a101 
DECLARE @END5 DATETIME2 = SYSDATETIME() 
SELECT 
    DATEDIFF(MILLISECOND,@START5,@END5) AS LOAD_TIME_T5
--------------------------------------------------- silver].[erp_px_cat_g1v2] --------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @START6 DATETIME2 = SYSDATETIME()
TRUNCATE TABLE [silver].[erp_px_cat_g1v2];
 insert into [silver].[erp_px_cat_g1v2]    /* No Change In This Column */
([id],
 [cat],
 [subcat],
 [maintenance]
)
select 
 [id],
 [cat],
 [subcat],
 [maintenance]   
from [bronze].[erp_px_cat_g1v2]
DECLARE @END6 DATETIME2= SYSDATETIME()
SELECT 
    DATEDIFF(MILLISECOND,@START6,@END6) AS LOAD_TIME_T6
------------------------------------------------------------------------------------------------------------------------------------------------
COMMIT
END TRY 
BEGIN CATCH 
 IF @@TRANCOUNT > 0  ROLLBACK
    SELECT ERROR_MESSAGE(),
           ERROR_LINE()
END CATCH
END                          ----PROCEDURE_END 

--------------------------------------------------------------------------------------------------------------
-------------------------------- EXECUATION OF SILVER.SILVER_LOAD ------------------------------------------
EXEC SILVER.SILVER_LOAD
-------------------------------------------------------------------------------------------------------------
