use PROJECT;
CREATE SCHEMA FACT3;

SELECT * FROM sys.schemas

SELECT TOP (1000) [BusinessEntityID]
      ,[TerritoryID]
  FROM [AdventureWorks2022].[Sales].[SalesPerson]

---- ##################################################################


SELECT [TerritoryID]
      ,[Name]
      ,[CountryRegionCode]
  FROM [AdventureWorks2022].[Sales].[SalesTerritory]


---- ##################################################################

  SELECT AHD.[DepartmentID]
      ,AHD.[Name]
      ,AHD.[GroupName]
  FROM [AdventureWorks2022].[HumanResources].[EmployeeDepartmentHistory] AHREDH JOIN [AdventureWorks2022].[HumanResources].[Department] AHD on AHD.DepartmentID = AHREDH.DepartmentID

 ---- ##################################################################

 -- EMPLOYEE DIM

 SELECT DISTINCT(AHE.[BusinessEntityID])
	  ,COALESCE(COALESCE(APP.[Title],'') + ' ' + COALESCE(APP.[FirstName],'') + ' ' + COALESCE(APP.[MiddleName],'') + ' ' + COALESCE(APP.[LastName],''),'') as EmployeeName
      ,AHE.[JobTitle]
      ,AHD.[DepartmentID]
      ,AHD.[Name] as DepartmentName
      ,AHD.[GroupName]
	  ,AHvE.[PhoneNumber]
      ,AHvE.[EmailAddress]
	  ,AHE.[BirthDate]
      ,AHE.[MaritalStatus]
      ,AHE.[Gender]
      ,AHE.[HireDate]
      ,AHE.[SalariedFlag]
      ,AHE.[CurrentFlag]
	  INTO PROJECT.FACT3.DimEmployee
  FROM [AdventureWorks2022].[HumanResources].[Employee] AHE
  JOIN [AdventureWorks2022].[Person].[Person] APP on AHE.BusinessEntityID = APP.BusinessEntityID
  JOIN [AdventureWorks2022].[HumanResources].[EmployeeDepartmentHistory] AHREDH  on AHE.BusinessEntityID = AHREDH.BusinessEntityID
  JOIN [AdventureWorks2022].[HumanResources].[vEmployee] AHvE on AHE.BusinessEntityID = AHvE.BusinessEntityID
  JOIN [AdventureWorks2022].[HumanResources].[Department] AHD on AHD.DepartmentID = AHREDH.DepartmentID
  ORDER BY EmployeeName,DepartmentName

  	    ALTER TABLE PROJECT.FACT3.DimEmployee 
	ALTER COLUMN [EmailAddress] nvarchar(50) NOT NULL


ALTER TABLE PROJECT.FACT3.DimEmployee
ADD CONSTRAINT PM_fact3_dim0
PRIMARY KEY ([BusinessEntityID], [DepartmentID],[EmailAddress]);

 ---- ##################################################################
 -- Territory Dim
 SELECT
       ASSP.[BusinessEntityID]
      ,ASST.[TerritoryID]
	  ,ASST.[Name] as TerritoryName
	  ,ASST.[CountryRegionCode]
	  INTO PROJECT.FACT3.DimTerritory
  FROM [AdventureWorks2022].[Sales].[SalesPerson] ASSP 
  JOIN [AdventureWorks2022].[Sales].[SalesTerritory] ASST on ASSP.TerritoryID = ASST.TerritoryID

  ALTER TABLE PROJECT.FACT3.DimTerritory
ADD CONSTRAINT PM_fact3_dim1
PRIMARY KEY ([BusinessEntityID]);


 ---- ##################################################################
 -- Vendor dim

 SELECT 
	   [AccountNumber]
      ,[VendorName]
      ,[StateProvinceName]
      ,[CountryRegionName]
      ,[ContactName]
      ,[PhoneNumber]
      ,[EmailAddress]
	   INTO PROJECT.FACT3.DimVendor
  FROM [PROJECT].[FACT2].[DimVendor]

  ALTER TABLE PROJECT.FACT3.DimVendor
ADD CONSTRAINT PM_fact3_dim2
PRIMARY KEY ([AccountNumber], [EmailAddress]);


 ---- ##################################################################
-- Vendor order dim

SELECT APPOH.[PurchaseOrderID]
	  ,APPOD.[PurchaseOrderDetailID]
      ,APPOH.[Status]
      ,APPOH.[EmployeeID]
      ,APPOH.[VendorID]
      ,APPOH.[ShipMethodID]
	  ,APSM.[Name] as ShipMethodName
      ,APPOH.[OrderDate]
      ,APPOH.[ShipDate]
      ,APPOH.[SubTotal]
      ,APPOH.[TaxAmt]
      ,APPOH.[Freight]
      ,APPOH.[TotalDue]
      ,APPOD.[DueDate]
      ,APPOD.[OrderQty]
      ,APPOD.[ProductID]
      ,APPOD.[UnitPrice]
      ,APPOD.[LineTotal]
      ,APPOD.[ReceivedQty]
      ,APPOD.[RejectedQty]
      ,APPOD.[StockedQty]
	  INTO PROJECT.fact3.DimVendorOrder
  FROM [AdventureWorks2022].[Purchasing].[PurchaseOrderHeader] as APPOH
  JOIN [AdventureWorks2022].[Purchasing].[ShipMethod] APSM on APPOH.ShipMethodID = APSM.ShipMethodID
  JOIN [AdventureWorks2022].[Purchasing].[PurchaseOrderDetail] as APPOD on APPOH.[PurchaseOrderID] = APPOD.PurchaseOrderID


    	    ALTER TABLE PROJECT.FACT3.DimVendorOrder 
	ALTER COLUMN [ProductID] INTEGER NOT NULL


	  	    ALTER TABLE PROJECT.FACT3.DimVendorOrder 
	ALTER COLUMN [PurchaseOrderID] INTEGER NOT NULL

		  	    ALTER TABLE PROJECT.FACT3.DimVendorOrder 
	ALTER COLUMN [PurchaseOrderDetailID] INTEGER NOT NULL

	  	    ALTER TABLE PROJECT.FACT3.DimVendorOrder 
	ALTER COLUMN [VendorID] INTEGER NOT NULL


	  	    ALTER TABLE PROJECT.FACT3.DimVendorOrder 
	ALTER COLUMN [EmployeeID] INTEGER NOT NULL


      ALTER TABLE PROJECT.FACT3.DimVendorOrder
ADD CONSTRAINT PM_fact3_dim4
PRIMARY KEY ([ProductID],[PurchaseOrderID],[PurchaseOrderDetailID],[VendorID],[EmployeeID]);

 ---- ##################################################################
 -- Product dim

SELECT ProductID
      ,[Name]
      ,[Color]
      ,[Size]
      ,[Class]
      ,[Style]
      ,[CategoryName]
      ,[SubCategoryName]
	  INTO PROJECT.FACT3.DimProduct
  FROM [PROJECT].[FACT2].[DimProduct]
  
    ALTER TABLE PROJECT.FACT3.DimProduct
ADD CONSTRAINT PM_fact3_dim3
PRIMARY KEY ([ProductID]);


   ---- ##################################################################
-- PRE FACT TABLE

SELECT PF3DVO.[PurchaseOrderID]
	  , PF3DVO.[PurchaseOrderDetailID]
      ,PF3DVO.[EmployeeID]
      ,PF3DVO.[VendorID]
      ,PF3DVO.[Status] /* Order current status. 1 = Pending; 2 = Approved; 3 = Rejected; 4 = Complete */
      ,PF3DVO.[SubTotal] as TotalOrderWithoutTF
      ,PF3DVO.[TaxAmt]
      ,PF3DVO.[Freight]
      ,PF3DVO.[TotalDue]
	  ,PF3DVO.[ProductID]
      ,PF3DVO.[OrderQty]
      ,PF3DVO.[UnitPrice]
      ,PF3DVO.[LineTotal] as TotalPerProductOrder    /*  SUM(PurchaseOrderDetail.LineTotal)for the appropriate PurchaseOrderID. */ 
      ,PF3DVO.[StockedQty] as AcceptedQty      /*Quantity accepted into inventory. Computed as ReceivedQty - RejectedQty. */
	  ,[StockedQty] * [UnitPrice] as [AcceptedTotal]
	  ,[OrderQty]-[StockedQty]  as OrderReturnQty
	  ,([OrderQty]-[StockedQty]) * [UnitPrice]  as [ReturnedTotal]   /*  mortagaa*/
	  ,PF3DVO.[OrderDate]
	  ,PF3DVO.[DueDate]
      ,PF3DVO.[ShipDate]
	  ,PF3DVO.[ShipMethodName]
	  INTO [PROJECT].[FACT3].[DimVendorOrderE]
  FROM [PROJECT].[FACT3].[DimVendorOrder] as PF3DVO
  order by [PurchaseOrderID]

      ALTER TABLE PROJECT.FACT3.[DimVendorOrderE] 
	ALTER COLUMN [ProductID] INTEGER NOT NULL


	  	    ALTER TABLE PROJECT.FACT3.[DimVendorOrderE] 
	ALTER COLUMN [PurchaseOrderID] INTEGER NOT NULL

		  	    ALTER TABLE PROJECT.FACT3.[DimVendorOrderE] 
	ALTER COLUMN [PurchaseOrderDetailID] INTEGER NOT NULL

	  	    ALTER TABLE PROJECT.FACT3.[DimVendorOrderE] 
	ALTER COLUMN [VendorID] INTEGER NOT NULL


	  	    ALTER TABLE PROJECT.FACT3.[DimVendorOrderE] 
	ALTER COLUMN [EmployeeID] INTEGER NOT NULL


      ALTER TABLE PROJECT.FACT3.[DimVendorOrderE]
ADD CONSTRAINT PM_fact3_dim5
PRIMARY KEY ([ProductID],[PurchaseOrderID],[PurchaseOrderDetailID],[VendorID],[EmployeeID]);

  /*TAXAmt = 8% of toal order*/
  /*Freight = 2.5% of toal order*/

 

--  FACT TABLE

SELECT PF3DVOE.[PurchaseOrderID]
	  ,PF3DVOE.[PurchaseOrderDetailID]
      ,PF3DVOE.[EmployeeID]
      ,PF3DVOE.[VendorID]
      ,PF3DVOE.[Status] /* Order current status. 1 = Pending; 2 = Approved; 3 = Rejected; 4 = Complete */
      ,PF3DVOE.TotalOrderWithoutTF
      ,PF3DVOE.[TaxAmt]
      ,PF3DVOE.[Freight]
      ,PF3DVOE.[TotalDue]
	  ,PF3DVOE.[ProductID]
      ,PF3DVOE.[OrderQty]
      ,PF3DVOE.[UnitPrice]
      ,PF3DVOE.TotalPerProductOrder    /*  SUM(PurchaseOrderDetail.LineTotal)for the appropriate PurchaseOrderID. */ 
      ,PF3DVOE.AcceptedQty      /*Quantity accepted into inventory. Computed as ReceivedQty - RejectedQty. */
	  ,PF3DVOE.AcceptedTotal
	  ,PF3DVOE.OrderReturnQty
	  ,PF3DVOE.ReturnedTotal   /*  mortagaa*/
	  ,SubQuery.ActualTotalOrderWihtoutTF
	  ,SubQuery.ActualTaxAmt
	  ,SubQuery.ActualFreight
	  ,SubQuery.ActualTotalDue
	  ,PF3DVOE.[OrderDate]
	  ,PF3DVOE.[DueDate]
      ,PF3DVOE.[ShipDate]
	  ,PF3DVOE.[ShipMethodName]
	  INTO [PROJECT].[FACT3].[FACT3]
  FROM [PROJECT].[FACT3].[DimVendorOrderE] as PF3DVOE JOIN (
			 SELECT
				   [PurchaseOrderID]
				  ,sum([AcceptedTotal]) as ActualTotalOrderWihtoutTF
				  ,sum([AcceptedTotal]) * 8 /100 as ActualTaxAmt
				  ,sum([AcceptedTotal]) * 2.5 /100 as ActualFreight
				  ,sum([AcceptedTotal]) + sum([AcceptedTotal]) * 8 /100 + sum([AcceptedTotal]) * 2.5 /100  as ActualTotalDue
		     FROM [PROJECT].[FACT3].[DimVendorOrderE]
             group by [PurchaseOrderID] ) as SubQuery on SubQuery.[PurchaseOrderID] = PF3DVOE.[PurchaseOrderID]
  order by [PurchaseOrderID]

  
    	    ALTER TABLE PROJECT.FACT3.[FACT3] 
	ALTER COLUMN [ProductID] INTEGER NOT NULL


	  	    ALTER TABLE PROJECT.FACT3.[FACT3] 
	ALTER COLUMN [PurchaseOrderID] INTEGER NOT NULL

		  	    ALTER TABLE PROJECT.FACT3.[FACT3] 
	ALTER COLUMN [PurchaseOrderDetailID] INTEGER NOT NULL

	  	    ALTER TABLE PROJECT.FACT3.[FACT3] 
	ALTER COLUMN [VendorID] INTEGER NOT NULL


	  	    ALTER TABLE PROJECT.FACT3.[FACT3] 
	ALTER COLUMN [EmployeeID] INTEGER NOT NULL


      ALTER TABLE PROJECT.FACT3.[FACT3]
ADD CONSTRAINT PM_fact3_dim7
PRIMARY KEY ([ProductID],[PurchaseOrderID],[PurchaseOrderDetailID],[VendorID],[EmployeeID]);



  SELECT
      pf3de.[EmployeeName]
      ,pf3de.[JobTitle]
      ,pf3de.[DepartmentName]
      ,pf3de.[GroupName]
      ,pf3de.[PhoneNumber]
      ,pf3de.[EmailAddress]
  FROM [PROJECT].[FACT3].[DimEmployee] as pf3de


 