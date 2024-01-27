create database project;

use project;
create schema f1;
/* ORDER DIM */

SELECT ASSOH.[SalesOrderID]
      ,ASSOH.[OrderDate]
	  ,ASSOD.[SalesOrderDetailID]
      ,SUM(ASSOD.[OrderQty]) as Total
      ,ASSOD.[ProductID]
  --INTO project.f1.order_dim
  FROM [AdventureWorks2022].[Sales].[SalesOrderHeader]  ASSOH JOIN [AdventureWorks2022].[Sales].[SalesOrderDetail] ASSOD on ASSOH.[SalesOrderID] = ASSOD.[SalesOrderID]
  group by ASSOH.[OrderDate] , ASSOD.[ProductID]
  order by ASSOD.[ProductID]


SELECT
      ASSOH.[OrderDate]
      ,SUM(ASSOD.[OrderQty]) as Total_Quantity
      ,ASSOD.[ProductID]
  INTO project.f1.order_dim
  FROM [AdventureWorks2022].[Sales].[SalesOrderHeader]  ASSOH JOIN [AdventureWorks2022].[Sales].[SalesOrderDetail] ASSOD on ASSOH.[SalesOrderID] = ASSOD.[SalesOrderID]
  /*where ProductID = 707 and [OrderDate] > '2012-6-1' and [OrderDate] < '2012-12-1'*/
  group by ASSOH.[OrderDate] , ASSOD.[ProductID]
  order by ASSOD.[ProductID] ,  ASSOH.[OrderDate]




/* Product DIM */
SELECT APP.[ProductID]
      ,APP.[Name] as ProductName
      ,APP.[Color]
      ,APP.[Size]
      ,APP.[Weight]
      ,APP.[Class]
      ,APP.[Style]
      ,APP.[ProductModelID]
      ,APPC.[ProductCategoryID]
      ,APPC.[Name] as CategoryName
      ,APPSC.[ProductSubcategoryID]
      ,APPSC.[Name] as SubCategoryName
  INTO project.f1.product_dim
  FROM [AdventureWorks2022].[Production].[Product] APP 
  JOIN [AdventureWorks2022].[Production].[ProductSubcategory] APPSC
  on APP.ProductSubcategoryID = APPSC.ProductSubcategoryID 
  JOIN [AdventureWorks2022].[Production].[ProductCategory] APPC 
  on APPC.[ProductCategoryID] = APPSC.[ProductCategoryID]


  SELECT pf1od.[OrderDate],
		Year([OrderDate]) as Order_Year,Month([OrderDate]) as Order_Month , Day([OrderDate]) as Order_Day,
		pf1od.Total_Quantity,
		pf1od.[ProductID],
		ProductName,
		pf1pd.[Color],
        pf1pd.[Size],
        pf1pd.[Weight],
        pf1pd.[Class],
        pf1pd.[Style],
		CategoryName,
		SubCategoryName
  INTO project.f1.fact1
  FROM project.f1.order_dim  pf1od join project.f1.product_dim pf1pd on pf1od.ProductID = pf1pd.ProductID
  order by pf1od.[ProductID];


  Drop table project.f1.fact1



ALTER TABLE project.f1.fact1
ADD FOREIGN KEY (PersonID,[OrderDate]) REFERENCES project.f1.order_dim(PersonID,[OrderDate]); 


ALTER TABLE project.f1.fact1
ADD FOREIGN KEY ([ProductID]) REFERENCES project.f1.order_dim([ProductID])
ADD FOREIGN KEY ([OrderDate]) REFERENCES project.f1.order_dim([OrderDate]); 


ALTER TABLE project.f1.fact1
ADD CONSTRAINT fk_fact10
FOREIGN KEY ([ProductID], [OrderDate])
REFERENCES project.f1.order_dim ([ProductID], [OrderDate]);

ALTER TABLE project.f1.fact1
ADD CONSTRAINT fk_fact11
FOREIGN KEY ([ProductID])
REFERENCES project.f1.product_dim ([ProductID]);

ALTER TABLE project.f1.order_dim
ADD CONSTRAINT fk_fact1
PRIMARY KEY ([ProductID], [OrderDate])


ALTER TABLE project.f1.product_dim
ADD CONSTRAINT fk_fact100
PRIMARY KEY ([ProductID])






ALTER TABLE [f1].[fact1]  WITH CHECK ADD  CONSTRAINT [fk_fact10] FOREIGN KEY([ProductID], [OrderDate])
REFERENCES [f1].[order_dim] ([ProductID], [OrderDate])
GO

ALTER TABLE [f1].[fact1] CHECK CONSTRAINT [fk_fact10]
GO

ALTER TABLE [f1].[fact1]  WITH CHECK ADD  CONSTRAINT [fk_fact11] FOREIGN KEY([ProductID])
REFERENCES [f1].[product_dim] ([ProductID])
GO

ALTER TABLE [f1].[fact1] CHECK CONSTRAINT [fk_fact11]
GO

