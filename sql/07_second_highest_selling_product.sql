/*Find the second-highest selling product by total sales amount.

SOLUTION APPROACH:
- ProductSales calculates total LineTotal by product.
- RankedProducts assigns RANK() based on revenue, highest first.
- The final filter selects rank 2.

IMPORTANT:
- RANK() can return multiple products tied at rank 2.
- If the requirement is the second distinct revenue value, this approach
  correctly treats ties as one rank. If exactly one row is required, consider
  ROW_NUMBER() with a deterministic tie-breaker instead.
==============================================================================*/
WITH ProductSales AS (
    SELECT
        p.ProductID,
        p.Name AS ProductName,
        SUM(sod.LineTotal) AS TotalSalesLineRevenue
    FROM Sales.SalesOrderDetail AS sod
    INNER JOIN Production.Product AS p
        ON p.ProductID = sod.ProductID
    GROUP BY p.ProductID, p.Name
),
RankedProducts AS (
    SELECT
        RANK() OVER (ORDER BY TotalSalesLineRevenue DESC) AS SalesRank,
        ProductID,
        ProductName,
        TotalSalesLineRevenue
    FROM ProductSales
)
SELECT
    SalesRank,
    ProductID,
    ProductName,
    TotalSalesLineRevenue
FROM RankedProducts
WHERE SalesRank = 2
ORDER BY ProductName;