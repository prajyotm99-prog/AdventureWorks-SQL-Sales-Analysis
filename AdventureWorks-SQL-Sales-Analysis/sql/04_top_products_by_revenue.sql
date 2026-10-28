/*
RANK() gives tied products the same rank and leaves gaps after ties.
Filtering SalesRank <= 10 returns all products whose rank is in the top
10 rank positions; ties can mean more than 10 rows.
*/
WITH ProductSales AS (
    SELECT
        p.ProductID,
        p.Name AS ProductName,
        SUM(sod.LineTotal) AS TotalSalesLineRevenue
    FROM Production.Product AS p
    INNER JOIN Sales.SalesOrderDetail AS sod
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
SELECT SalesRank, ProductID, ProductName, TotalSalesLineRevenue
FROM RankedProducts
WHERE SalesRank <= 10
ORDER BY SalesRank, ProductName;
