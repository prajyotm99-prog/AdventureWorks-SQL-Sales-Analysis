/*
Business question: Total quantity ordered for every product, including
products without matching sales-order detail records.
*/
SELECT
    p.ProductID,
    p.Name AS ProductName,
    ISNULL(SUM(sod.OrderQty), 0) AS TotalQuantityOrdered
FROM Production.Product AS p
LEFT JOIN Sales.SalesOrderDetail AS sod
    ON p.ProductID = sod.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY TotalQuantityOrdered DESC, p.Name;
