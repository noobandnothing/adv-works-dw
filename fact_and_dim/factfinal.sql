SELECT [Year]
      ,SUM([Total_Payed_SALES]-[Tax_Freight_SALES]) AS sales_AMOUNT 
  FROM [project].[FACT4].[dimOrderSales]
  GROUP BY  [Year]



  UNION ALL


  SELECT [Year] as y
      ,SUM([Total_Payed] - [Tax_Freight])  AS purchase_AMOUNT
      FROM [project].[FACT4].[PURCHASE]
  GROUP BY  [Year]




  SELECT sales.[Year]
    , sales.sales_AMOUNT
    , purchase.purchase_AMOUNT
	,sales.sales_AMOUNT - purchase_AMOUNT as Profit
	into project.fact4.fact4
FROM (
    SELECT [Year]
        , SUM([Total_Payed_SALES] - [Tax_Freight_SALES]) AS sales_AMOUNT
    FROM [project].[FACT4].[dimOrderSales]
    GROUP BY [Year]
) AS sales
JOIN (
    SELECT [Year]
        , SUM([Total_Payed] - [Tax_Freight]) AS purchase_AMOUNT
    FROM [project].[FACT4].[PURCHASE]
    GROUP BY [Year]
) AS purchase ON sales.[Year] = purchase.[Year];