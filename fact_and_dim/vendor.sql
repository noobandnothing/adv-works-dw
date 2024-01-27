CREATE DATABASE PROJECT;

use project;
CREATE SCHEMA FACT2;


-- VENDOR DIM 
SELECT [BusinessEntityID]
      ,[AccountNumber]
      ,[Name]
  FROM [AdventureWorks2022].[Purchasing].[Vendor]


-- ADDRESS DIM

SELECT [AddressID]
      ,[AddressLine1]
      ,[City]
      ,[StateProvinceID]
  FROM [AdventureWorks2022].[Person].[Address]


--  Dim Person 
SELECT [BusinessEntityID]
      ,[AddressID]
      ,[AddressTypeID]
  FROM [AdventureWorks2022].[Person].[BusinessEntityAddress]



USE [AdventureWorks2022];

SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    COLUMN_NAME LIKE '%phone%';


	--- ################################################

-- DIM VENDOR WIITH ADDRESS

SELECT APV.[BusinessEntityID],
      APV.[AccountNumber],
      APV.[Name],
	  APBEA.[AddressID],
	  APA.[AddressLine1],
      APA.[City],
      APA.[StateProvinceID]
  FROM 
  [AdventureWorks2022].[Purchasing].[Vendor] APV JOIN [AdventureWorks2022].[Person].[BusinessEntityAddress] APBEA on  APV.BusinessEntityID = APBEA.BusinessEntityID
  JOIN [AdventureWorks2022].[Person].[Address] APA on APBEA.AddressID = APA.AddressID




--- DIM VENDOR WITH CONTACT 

SELECT 
	   COALESCE (APP.FirstName + ' '+ APP.MiddleName + ' ' +APP.LastName ,'NO NAME') as ContactName, 
	  APCT.[Name] as 'ContanctType'
  FROM [AdventureWorks2022].[Person].[BusinessEntityContact] APBC JOIN [AdventureWorks2022].[Person].[ContactType] APCT on APBC.[ContactTypeID] = APCT.[ContactTypeID]
  JOIN [AdventureWorks2022].[Person].Person APP on  APBC.PersonID = APP.BusinessEntityID


---- 


SELECT APV.[BusinessEntityID],
      APV.[AccountNumber],
      APV.[Name],
	  APBEA.[AddressID],
	  APA.[AddressLine1],
      APA.[City],
      APA.[StateProvinceID],
	   COALESCE (APP.FirstName + ' '+ APP.MiddleName + ' ' +APP.LastName ,'NO NAME') as ContactName, 
	  APCT.[Name] as 'ContanctType'
  FROM 
  [AdventureWorks2022].[Purchasing].[Vendor] APV JOIN [AdventureWorks2022].[Person].[BusinessEntityAddress] APBEA on  APV.BusinessEntityID = APBEA.BusinessEntityID
  JOIN [AdventureWorks2022].[Person].[Address] APA on APBEA.AddressID = APA.AddressID JOIN [AdventureWorks2022].[Person].[BusinessEntityContact] APBC  on APV.BusinessEntityID =  APBC.BusinessEntityID
  JOIN [AdventureWorks2022].[Person].[ContactType] APCT on APBC.[ContactTypeID] = APCT.[ContactTypeID]
  JOIN [AdventureWorks2022].[Person].Person APP on  APBC.PersonID = APP.BusinessEntityID


--- TRY

-- DIM VENDOR
SELECT APV.[BusinessEntityID]
      ,APV.[AccountNumber]
      ,APvVWC.[Name] as VendorName
	  ,APVWA.[AddressLine1]
      ,APVWA.[City]
      ,APVWA.[StateProvinceName]
      ,APVWA.[CountryRegionName]
      ,[ContactType]
      ,COALESCE(COALESCE(APvVWC.[Title],'') + ' ' + COALESCE(APvVWC.[FirstName],'') + ' ' + COALESCE(APvVWC.[MiddleName],'') + ' ' + COALESCE(APvVWC.[LastName],''),'') as ContactName,
	  APvVWC.[PhoneNumber],
      APvVWC.[EmailAddress]
	  INTO PROJECT.FACT2.DimVendor
FROM[AdventureWorks2022].[Purchasing].[Vendor] as APV 
JOIN [AdventureWorks2022].[Purchasing].[vVendorWithAddresses] APVWA on  APV.[BusinessEntityID] = APVWA.BusinessEntityID 
JOIN [AdventureWorks2022].[Purchasing].[vVendorWithContacts]  APvVWC on  APV.[BusinessEntityID] = APvVWC.BusinessEntityID 

ALTER TABLE [project].[FACT2].[DimVendor] ALTER COLUMN [EmailAddress] nvarchar(50) NOT NULL

ALTER TABLE PROJECT.FACT2.DimVendor
ADD CONSTRAINT PM_fact2_dim0
PRIMARY KEY ([BusinessEntityID], [AccountNumber],[EmailAddress]);


-- DIM PRODUCT

SELECT APP.[ProductID]
      ,APP.[Name]
      ,APP.[ProductNumber]
      ,APP.[MakeFlag]
      ,APP.[Color]
      ,APP.[StandardCost]
      ,APP.[ListPrice]
      ,APP.[Size]
      ,APP.[ProductLine]
      ,APP.[Class]
      ,APP.[Style]
      ,APP.[ProductSubcategoryID] 
      ,APP.[ProductModelID]
      ,APP.[SellStartDate]
      ,APP.[SellEndDate]
      ,APP.[DaysToManufacture]
      ,APPC.[ProductCategoryID]
      ,APPC.[Name] as CategoryName
      ,APPSC.[Name] as SubCategoryName
	INTO PROJECT.FACT2.DimProduct
  FROM [AdventureWorks2022].[Production].[Product] APP
  FULL OUTER JOIN [AdventureWorks2022].[Production].[ProductSubcategory]  APPSC ON APP.ProductSubcategoryID = APPSC.ProductSubcategoryID
  FULL OUTER JOIN [AdventureWorks2022].[Production].[ProductCategory] APPC on APPC.ProductCategoryID = APPSC.ProductCategoryID

  ALTER TABLE PROJECT.FACT2.DimProduct ALTER COLUMN [ProductID] INTEGER NOT NULL

  ALTER TABLE PROJECT.FACT2.DimProduct
  ADD CONSTRAINT PM_fact2_dim1
PRIMARY KEY ([ProductID]);

  -- DIM PRODUCT VENDOR
  SELECT 
	   APPV.[ProductID]
      ,APPV.[BusinessEntityID]
      ,APPV.[AverageLeadTime]
      ,APPV.[StandardPrice]
      ,APPV.[LastReceiptCost]
      ,APPV.[LastReceiptDate]
      ,APPV.[MinOrderQty]
      ,APPV.[MaxOrderQty]
      ,APPV.[OnOrderQty]
	  INTO PROJECT.FACT2.DimProductVendor
  FROM [AdventureWorks2022].[Purchasing].[ProductVendor] as APPV

    ALTER TABLE PROJECT.FACT2.DimProductVendor 
	ALTER COLUMN [ProductID] INTEGER NOT NULL
	
	ALTER TABLE PROJECT.FACT2.DimProductVendor 
	ALTER COLUMN [BusinessEntityID] INTEGER NOT NULL

	  ALTER TABLE PROJECT.FACT2.DimProductVendor
	 ADD CONSTRAINT PM_fact2_dim2
	PRIMARY KEY ([ProductID],[BusinessEntityID]);

  -- FACT TABLE 2 

select PDF2DP.ProductID,
	   PDF2DP.Name,
	   PDF2DP.Color,
	   PDF2DP.Size,
	   PDF2DP.StandardCost,
	   PDF2DP.CategoryName,
	   PDF2DP.SubCategoryName,
	   PDF2DV.[BusinessEntityID],
	   PDF2DV.[AccountNumber],
	   PDF2DV.VendorName,
	   PDF2DV.[AddressLine1],
       PDF2DV.[City],
       PDF2DV.[StateProvinceName],
       PDF2DV.[CountryRegionName],
	   PDF2DV.ContactName,
	   PDF2DV.[PhoneNumber],
	   PDF2DV.EmailAddress
	   INTO PROJECT.FACT2.Fact2
FROM PROJECT.FACT2.DimProduct as PDF2DP
JOIN PROJECT.FACT2.DimProductVendor as  PDF2DPV on PDF2DP.ProductID = PDF2DPV.ProductID
JOIN PROJECT.FACT2.DimVendor PDF2DV on PDF2DV.BusinessEntityID = PDF2DPV.BusinessEntityID
ORDER BY PDF2DP.Name ,PDF2DV.VendorName


    ALTER TABLE PROJECT.FACT2.Fact2 
	ALTER COLUMN [ProductID] INTEGER NOT NULL

	    ALTER TABLE PROJECT.FACT2.Fact2 
	ALTER COLUMN EmailAddress nvarchar(50) NOT NULL


USE [project]
GO

/****** Object:  Table [FACT2].[Fact2]    Script Date: 12/26/2023 6:27:28 AM ******/

ALTER TABLE [FACT2].[Fact2]  WITH CHECK ADD  CONSTRAINT [FK_Fact2_DimProduct] FOREIGN KEY([ProductID])
REFERENCES [FACT2].[DimProduct] ([ProductID])
GO

ALTER TABLE [FACT2].[Fact2] CHECK CONSTRAINT [FK_Fact2_DimProduct]
GO

ALTER TABLE [FACT2].[Fact2]  WITH CHECK ADD  CONSTRAINT [FK_Fact2_DimProductVendor] FOREIGN KEY([ProductID], [BusinessEntityID])
REFERENCES [FACT2].[DimProductVendor] ([ProductID], [BusinessEntityID])
GO

ALTER TABLE [FACT2].[Fact2] CHECK CONSTRAINT [FK_Fact2_DimProductVendor]
GO

ALTER TABLE [FACT2].[Fact2]  WITH CHECK ADD  CONSTRAINT [PM_fact2_0] FOREIGN KEY([BusinessEntityID], [AccountNumber], [EmailAddress])
REFERENCES [FACT2].[DimVendor] ([BusinessEntityID], [AccountNumber], [EmailAddress])
GO

ALTER TABLE [FACT2].[Fact2] CHECK CONSTRAINT [PM_fact2_0]
GO

