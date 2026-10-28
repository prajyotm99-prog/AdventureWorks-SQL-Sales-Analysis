/*
TotalDue includes tax and freight; it is distinct from LineTotal used for
product/category sales-line revenue. Returns customers with sales orders.
*/
SELECT
    c.CustomerID,
    SUM(soh.TotalDue) AS TotalCustomerOrderValue,
    COUNT(DISTINCT soh.SalesOrderID) AS SalesOrderCount
FROM Sales.Customer AS c
INNER JOIN Sales.SalesOrderHeader AS soh
    ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID
ORDER BY TotalCustomerOrderValue DESC;
