use project;
create schema FACT4;
SELECT ASSOH.[SalesOrderID]
	      ,A.[SalesOrderDetailID]
      ,[OrderDate] 
	  ,Year([OrderDate])as Year
	   ,Month([OrderDate])as Month
	   ,Day([OrderDate]) as Day
      ,[PurchaseOrderNumber]
      ,[CustomerID]
	  
      ,SUM([TaxAmt]+[Freight]) AS Tax_Freight_SALES
      ,sum([TotalDue]) AS Total_Payed_SALES
	  INTO project.FACT4.dimOrderSales
  FROM [AdventureWorks2022].[Sales].[SalesOrderHeader] ASSOH JOIN   [AdventureWorks2022].[Sales].[SalesOrderDetail] A On A.[SalesOrderID] =  ASSOH.[SalesOrderID]
  where ASSOH.Status != 4 and ASSOH.Status != 6
  group by ASSOH.[SalesOrderID] , [SalesOrderDetailID],[OrderDate]      ,[PurchaseOrderNumber]      ,[CustomerID]
  order by ASSOH.[SalesOrderID] , [SalesOrderDetailID],[OrderDate]



  
	  	    ALTER TABLE PROJECT.FACT4.dimOrderSales 
	ALTER COLUMN [SalesOrderID] INTEGER NOT NULL

  
	  	    ALTER TABLE PROJECT.FACT4.dimOrderSales 
	ALTER COLUMN [SalesOrderDetailID] INTEGER NOT NULL
	  
	  	    ALTER TABLE PROJECT.FACT4.dimOrderSales 
	ALTER COLUMN [CustomerID] integer NOT NULL

		  	    ALTER TABLE PROJECT.FACT4.dimOrderSales 
	ALTER COLUMN [PurchaseOrderNumber] nvarchar(25) NOT NULL

	ALTER TABLE PROJECT.FACT4.dimOrderSales
ADD CONSTRAINT PM_fact4_dim1
PRIMARY KEY ([SalesOrderDetailID],[SalesOrderID])





  SELECT [PurchaseOrderID]
         ,[PurchaseOrderDetailID]
		,[OrderDate]
	   ,Year([OrderDate])as Year
	   ,Month([OrderDate])as Month
	   ,Day([OrderDate]) as Day
      ,SUM([ActualTotalDue]) Total_Payed
	  ,Sum(ActualTaxAmt+ActualFreight) Tax_Freight 
	 INTO [project].FACT4.[PURCHASE]
  FROM [project].[FACT3].[FACT3]
  group by [PurchaseOrderID] , [PurchaseOrderDetailID],[OrderDate]
  order by [PurchaseOrderID] , [PurchaseOrderDetailID],[OrderDate]



  
	  	    ALTER TABLE PROJECT.FACT4.[PURCHASE] 
	ALTER COLUMN [PurchaseOrderID] INTEGER NOT NULL

  
	  	    ALTER TABLE PROJECT.FACT4.[PURCHASE] 
	ALTER COLUMN [PurchaseOrderDetailID] INTEGER NOT NULL
	  
	  	    ALTER TABLE PROJECT.FACT4.[PURCHASE] 
	ALTER COLUMN [OrderDate] date NOT NULL

	ALTER TABLE PROJECT.FACT4.[PURCHASE]
ADD CONSTRAINT PM_fact4_dim2
PRIMARY KEY ([PurchaseOrderID],[PurchaseOrderDetailID])




