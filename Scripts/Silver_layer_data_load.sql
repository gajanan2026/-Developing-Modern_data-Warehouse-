
-------------------------------------------------------------------------   [silver].[crm_cust_info] Data Transformation And Loading -------------------------------------------------------------------------------------------------------

IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE,
    dwh_creat_time datetime2 default getdate()
);
GO
---------------------------------------------------------------------------------
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
        WHEN upper([cst_marital_status]) = 's' THEN 'Single'
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
  
-------------------------------------------------------------------    [silver].[crm_prd_info] Data Transformation And Loading   -----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL          
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
    prd_id       INT,
    cat_id       NVARCHAR(50),
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt   DATE,
    dwh_creat_time datetime2 default getdate()
);
GO
-------------------------------------------------------------------------------------------
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
	WHEN UPPER(TRIM( [prd_line]))= 'S'  THEN 'Othersales'
	WHEN UPPER(TRIM( [prd_line]))= 'T'  THEN 'Tourning'
	ELSE 'NA'
END AS[prd_line],
	  CAST([prd_start_dt]AS date) AS [prd_start_dt] ,
	  CAST(LEAD([prd_start_dt]) OVER(PARTITION BY [prd_key] ORDER BY [prd_start_dt]) -1  AS DATE) AS [prd_end_dt]
from bronze.crm_prd_info

-------------------------------------------------------------- [silver].[crm_sales_details]] Data Transformation And Loading  ---------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* SOME CHANGES NEEDED  
    sls_order_dt DATE,
    sls_ship_dt  DATE,
    sls_due_dt   DATE,  WE CHANE DATATYPE IN THIS SCHEMA FROM INT TO NUMBER */
    
IF OBJECT_ID('SILVER.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE SILVER.crm_sales_details;
GO

CREATE TABLE SILVER.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt DATE,     -- DATATYPE CHANGE 
    sls_ship_dt  DATE,     -- DATATYPE CHANGE
    sls_due_dt   DATE,     -- DATATYPE CHANGE
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT,
    dwh_creat_time DATETIME DEFAULT GETDATE()
);
GO

-------------------------------------------------------------------------
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

------------------------------------------------------------------------------    [silver].[erp_cust_az12]] Data Transformation And Loading  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
    cid    NVARCHAR(50),
    bdate  DATE,
    gen    NVARCHAR(50),
    dwh_creat_time datetime2 default getdate()
);
GO
------------------------------------------------------------------------------
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
    WHEN GEN = 'MALE' THEN  TRIM(GEN)
    WHEN GEN = 'Female' THEN TRIM(GEN)
    ELSE GEN
END  as gen   
from [bronze].[erp_cust_az12] 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
