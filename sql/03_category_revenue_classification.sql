/*
Thresholds: High > $1,000,000; Medium >= $500,000 and <= $1,000,000;
Low < $500,000. These are project-defined thresholds.
LEFT JOINs retain categories with no matching sales; their revenue is zero.
*/
WITH CategoryRevenue AS (
    SELECT
        pc.ProductCategoryID,
        pc.Name AS CategoryName,
        ISNULL(SUM(sod.LineTotal), 0) AS TotalSalesLineRevenue
    FROM Production.ProductCategory AS pc
    LEFT JOIN Production.ProductSubcategory AS psc
        ON pc.ProductCategoryID = psc.ProductCategoryID
    LEFT JOIN Production.Product AS p
        ON psc.ProductSubcategoryID = p.ProductSubcategoryID
    LEFT JOIN Sales.SalesOrderDetail AS sod
        ON p.ProductID = sod.ProductID
    GROUP BY pc.ProductCategoryID, pc.Name
)
SELECT
    ProductCategoryID,
    CategoryName,
    TotalSalesLineRevenue,
    CASE
        WHEN TotalSalesLineRevenue > 1000000 THEN 'High Revenue'
        WHEN TotalSalesLineRevenue >= 500000 THEN 'Medium Revenue'
        ELSE 'Low Revenue'
    END AS RevenueClassification
FROM CategoryRevenue
ORDER BY TotalSalesLineRevenue DESC, CategoryName;
