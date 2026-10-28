/*
Purpose: Overall sales-line revenue, quantity ordered, detail-line count,
and distinct sales-order count.
LineTotal is used as sales-line revenue.
*/
SELECT
    SUM(LineTotal) AS TotalSalesLineRevenue,
    SUM(OrderQty) AS TotalQuantityOrdered,
    COUNT(*) AS SalesOrderDetailLineCount,
    COUNT(DISTINCT SalesOrderID) AS DistinctSalesOrderCount
FROM Sales.SalesOrderDetail;
