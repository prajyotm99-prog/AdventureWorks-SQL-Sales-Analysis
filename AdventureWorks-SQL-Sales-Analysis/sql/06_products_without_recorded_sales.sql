/*
Products with no matching sales-order detail rows.
This does not by itself mean the product is discontinued or unsuccessful.
*/
SELECT
    p.ProductID,
    p.Name AS ProductName,
    p.ListPrice,
    p.SellStartDate,
    p.SellEndDate
FROM Production.Product AS p
LEFT JOIN Sales.SalesOrderDetail AS sod
    ON p.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL
ORDER BY p.Name;
