/*
================================================================================
PROJECT: AdventureWorks2019 SQL Practice and Sales Analysis
DATABASE: AdventureWorks2019
PURPOSE: Practice SQL joins, aggregation, filtering, CTEs, ranking, and CASE.
AUTHOR: Prajyot Meshram

HOW TO USE:
1. Open this file in SQL Server Management Studio (SSMS).
2. Confirm the database name is AdventureWorks2019.
3. Run each numbered section separately to review its output.
4. Comments explain the business question, solution approach, and important
   interpretation notes.

METRIC NOTES:
- SalesOrderDetail.LineTotal is used for sales-line revenue.
- SalesOrderHeader.TotalDue includes tax and freight.
- OrderQty is quantity on sales-order detail lines, not necessarily shipped qty.
- EmployeePayHistory.Rate is an hourly pay rate, not annual salary.
================================================================================
*/

USE AdventureWorks2019;
GO

/*==============================================================================
QUESTION 01 — Retrieve employees' first name, last name, email, and job title.

SOLUTION APPROACH:
- Join Person.Person to HumanResources.Employee using BusinessEntityID.
- LEFT JOIN email addresses so an employee is retained even if no email row
  exists in Person.EmailAddress.
==============================================================================*/
SELECT
    p.FirstName,
    p.LastName,
    e.EmailAddress,
    hr.JobTitle
FROM Person.Person AS p
INNER JOIN HumanResources.Employee AS hr
    ON hr.BusinessEntityID = p.BusinessEntityID
LEFT JOIN Person.EmailAddress AS e
    ON e.BusinessEntityID = p.BusinessEntityID;
GO

/*==============================================================================
QUESTION 02 — Count all product records.

SOLUTION APPROACH:
- COUNT(*) counts every row in Production.Product.
==============================================================================*/
SELECT COUNT(*) AS ProductCount
FROM Production.Product;
GO

/*==============================================================================
QUESTION 03 — Calculate total sales value for each customer.

SOLUTION APPROACH:
- Join each customer to their sales orders using CustomerID.
- SUM(TotalDue) adds the total due across the customer's orders.
- GROUP BY returns one row per customer who has at least one order.

INTERPRETATION:
- TotalDue includes tax and freight; it is not the same as sales-line revenue.
- INNER JOIN excludes customers with no sales orders.
==============================================================================*/
SELECT
    c.CustomerID,
    SUM(soh.TotalDue) AS TotalCustomerOrderValue
FROM Sales.Customer AS c
INNER JOIN Sales.SalesOrderHeader AS soh
    ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID
ORDER BY TotalCustomerOrderValue DESC;
GO

/*==============================================================================
QUESTION 04 — Calculate the average list price across all products.

SOLUTION APPROACH:
- AVG(ListPrice) calculates the mean of non-NULL list prices.
- Products with a ListPrice of 0 are included in the average.
==============================================================================*/
SELECT AVG(p.ListPrice) AS AverageListPrice
FROM Production.Product AS p;
GO

/*==============================================================================
QUESTION 05 — Calculate average, minimum, and maximum list price by category.

SOLUTION APPROACH:
- ProductSubcategory links each product to its ProductCategoryID.
- Aggregate ListPrice by category.
- The derived table keeps the join path separate from the aggregation.

NOTE:
- This query includes categories represented by products that have a
  subcategory. Products without a subcategory are not included.
==============================================================================*/
SELECT
    x.ProductCategoryID,
    AVG(x.ListPrice) AS AverageListPrice,
    MIN(x.ListPrice) AS MinimumListPrice,
    MAX(x.ListPrice) AS MaximumListPrice
FROM (
    SELECT
        p.ProductID,
        p.ProductSubcategoryID,
        ps.ProductCategoryID,
        p.ListPrice
    FROM Production.Product AS p
    INNER JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
) AS x
GROUP BY x.ProductCategoryID
ORDER BY x.ProductCategoryID;
GO

/*==============================================================================
QUESTION 06 — Find departments that currently have more than 10 employees.

SOLUTION APPROACH:
- EndDate IS NULL identifies current department assignments.
- COUNT(DISTINCT BusinessEntityID) counts employees, not history rows.
- HAVING filters the grouped departments to those with more than 10 employees.

CORRECTION:
- Count BusinessEntityID. Counting DepartmentID would count the department
  identifier, not the number of employees in the department.
==============================================================================*/
SELECT
    d.DepartmentID,
    d.Name AS DepartmentName,
    x.EmployeeCount
FROM HumanResources.Department AS d
INNER JOIN (
    SELECT
        edh.DepartmentID,
        COUNT(DISTINCT edh.BusinessEntityID) AS EmployeeCount
    FROM HumanResources.EmployeeDepartmentHistory AS edh
    WHERE edh.EndDate IS NULL
    GROUP BY edh.DepartmentID
    HAVING COUNT(DISTINCT edh.BusinessEntityID) > 10
) AS x
    ON x.DepartmentID = d.DepartmentID
ORDER BY x.EmployeeCount DESC;
GO

/*==============================================================================
QUESTION 07 — Find products that have never appeared in sales-order details.

SOLUTION APPROACH:
- LEFT JOIN keeps every product.
- A NULL sales-side ProductID means no matching sales detail row was found.

INTERPRETATION:
- This means no matching sales detail is recorded; it does not alone prove
  the product is discontinued or commercially unsuccessful.
==============================================================================*/
SELECT
    p.ProductID,
    p.Name AS ProductName
FROM Production.Product AS p
LEFT JOIN Sales.SalesOrderDetail AS sod
    ON p.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL
ORDER BY p.Name;
GO

/*==============================================================================
QUESTION 08 — Find employees with a department-history StartDate in 2010.

SOLUTION APPROACH:
- First find distinct BusinessEntityID values with assignment StartDate
  between January 1, 2010 (inclusive) and January 1, 2011 (exclusive).
- Join those IDs to Person.Person to retrieve names.

IMPORTANT:
- This is the start date of a department-history record, not necessarily the
  employee's original hire date.
- A date range is generally preferable to DATEPART(year, StartDate) in filters.
==============================================================================*/
SELECT DISTINCT
    p.BusinessEntityID,
    p.FirstName,
    p.LastName
FROM Person.Person AS p
INNER JOIN HumanResources.EmployeeDepartmentHistory AS edh
    ON edh.BusinessEntityID = p.BusinessEntityID
WHERE edh.StartDate >= '20100101'
  AND edh.StartDate <  '20110101'
ORDER BY p.LastName, p.FirstName;
GO

/*==============================================================================
QUESTION 09 — Display full names of individual customers in uppercase.

SOLUTION APPROACH:
- Sales.Customer.PersonID links an individual customer to Person.Person.
- UPPER converts the combined first and last name to uppercase.
- CONCAT safely combines the name parts.

NOTE:
- INNER JOIN excludes customers without a linked Person record, such as store
  customers that do not represent an individual person.
==============================================================================*/
SELECT DISTINCT
    UPPER(CONCAT(p.FirstName, ' ', p.LastName)) AS FullName
FROM Sales.Customer AS c
INNER JOIN Person.Person AS p
    ON c.PersonID = p.BusinessEntityID
ORDER BY FullName;
GO

/*==============================================================================
QUESTION 10 — List sales order lines with product details and salesperson name.

SOLUTION APPROACH:
- SalesOrderHeader identifies the order and salesperson.
- SalesOrderDetail supplies product IDs and order quantities.
- Production.Product supplies the product name.
- LEFT JOIN to Person.Person preserves rows when SalesPersonID is NULL.

OUTPUT GRAIN:
- One row per matching sales-order detail line, not one row per order.
==============================================================================*/
SELECT
    p.SalesOrderID,
    p.ProductName,
    p.OrderQty,
    CONCAT(q.FirstName, ' ', q.LastName) AS SalespersonName
FROM (
    SELECT
        soh.SalesOrderID,
        soh.SalesPersonID,
        sod.OrderQty,
        prod.ProductID,
        prod.Name AS ProductName
    FROM Sales.SalesOrderHeader AS soh
    INNER JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
    INNER JOIN Production.Product AS prod
        ON sod.ProductID = prod.ProductID
) AS p
LEFT JOIN Person.Person AS q
    ON p.SalesPersonID = q.BusinessEntityID
ORDER BY p.SalesOrderID, p.ProductName;
GO

/*==============================================================================
QUESTION 11 — Find products that appear on exactly one sales-order detail row.

SOLUTION APPROACH:
- Group sales-order detail rows by ProductID.
- HAVING COUNT(*) = 1 keeps products with exactly one detail row.

IMPORTANT:
- This counts detail rows, not total units sold. A single row can have
  OrderQty greater than 1.
==============================================================================*/
SELECT
    sod.ProductID,
    COUNT(*) AS SalesOrderDetailRowCount
FROM Sales.SalesOrderDetail AS sod
GROUP BY sod.ProductID
HAVING COUNT(*) = 1;
GO

/*==============================================================================
QUESTION 12 — Calculate average recorded hourly pay rate by current department.

SOLUTION APPROACH:
- LEFT JOIN from Department preserves departments even if no current employees
  or matching pay-history rows exist.
- EndDate IS NULL restricts EmployeeDepartmentHistory to current assignments.
- ISNULL changes a NULL average to 0 for display.

IMPORTANT INTERPRETATION:
- EmployeePayHistory.Rate is an hourly pay rate, not annual salary.
- If employees have multiple pay-history rows, this averages all matching
  pay-history rates. It does not select only each employee's latest rate.
==============================================================================*/
SELECT
    d.DepartmentID,
    d.Name AS DepartmentName,
    ISNULL(AVG(eph.Rate), 0) AS AverageRecordedHourlyRate
FROM HumanResources.Department AS d
LEFT JOIN HumanResources.EmployeeDepartmentHistory AS edh
    ON d.DepartmentID = edh.DepartmentID
   AND edh.EndDate IS NULL
LEFT JOIN HumanResources.EmployeePayHistory AS eph
    ON edh.BusinessEntityID = eph.BusinessEntityID
GROUP BY d.DepartmentID, d.Name
ORDER BY d.DepartmentID;
GO

/*==============================================================================
QUESTION 13 — Retrieve the top 10 products by total sales-line revenue.

SOLUTION APPROACH:
- SUM(LineTotal) calculates revenue per product.
- GROUP BY produces one row per product.
- TOP (10) and ORDER BY DESC return the 10 highest-revenue product rows.

METRIC:
- LineTotal is the sales-line revenue measure used in this project.
==============================================================================*/
SELECT TOP (10)
    p.ProductID,
    p.Name AS ProductName,
    SUM(sod.LineTotal) AS TotalSalesLineRevenue
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Production.Product AS p
    ON p.ProductID = sod.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY TotalSalesLineRevenue DESC;
GO

/*==============================================================================
QUESTION 14 — Rank products by total sales-line revenue and show the top 10 rows.

SOLUTION APPROACH:
- The CTE first calculates total revenue per product.
- RANK() assigns rank 1 to the highest revenue.
- Tied revenue totals receive the same rank.

IMPORTANT:
- TOP (10) limits the output to at most 10 rows; ties can affect which rows
  are returned at the cutoff. To return all products in the top 10 rank
  positions, filter a ranked CTE with WHERE SalesRank <= 10 instead.
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
)
SELECT TOP (10)
    RANK() OVER (ORDER BY TotalSalesLineRevenue DESC) AS SalesRank,
    ProductID,
    ProductName,
    TotalSalesLineRevenue
FROM ProductSales
ORDER BY TotalSalesLineRevenue DESC;
GO

/*==============================================================================
QUESTION 15 — List every product and total quantity ordered, including products
              that have never been sold.

SOLUTION APPROACH:
- LEFT JOIN retains every row from Production.Product.
- SUM(OrderQty) calculates total quantity on matching sales detail rows.
- ISNULL converts NULL (no matching detail rows) to 0.
- Group by product ID and name to return one row per product.

WHY GROUP BY DOES NOT INCLUDE OrderQty:
- Grouping by OrderQty would split a product into separate quantity groups.
==============================================================================*/
SELECT
    p.ProductID,
    p.Name AS ProductName,
    ISNULL(SUM(sod.OrderQty), 0) AS TotalQuantityOrdered
FROM Production.Product AS p
LEFT JOIN Sales.SalesOrderDetail AS sod
    ON p.ProductID = sod.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY TotalQuantityOrdered DESC, p.Name;
GO

/*==============================================================================
QUESTION 16 — Find the second-highest selling product by total sales amount.

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
GO

/*==============================================================================
QUESTION 17 — Calculate revenue by product category and classify each category.

BUSINESS RULES:
- High Revenue:   Total revenue > $1,000,000
- Medium Revenue: Total revenue >= $500,000 and <= $1,000,000
- Low Revenue:    Total revenue < $500,000

SOLUTION APPROACH:
- Join Product to ProductSubcategory, then ProductCategory.
- Join products to SalesOrderDetail.
- SUM(LineTotal) calculates category sales-line revenue.
- CTE calculates totals first so the outer query can reference TotalRevenue
  inside CASE.

SCOPE NOTE:
- INNER JOINs mean categories with no matching sales details are not included.
- These revenue thresholds are defined for this exercise, not official
  AdventureWorks classifications.
==============================================================================*/
WITH CategoryRevenue AS (
    SELECT
        pc.ProductCategoryID,
        pc.Name AS CategoryName,
        SUM(sod.LineTotal) AS TotalRevenue
    FROM Production.Product AS p
    INNER JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    INNER JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
    INNER JOIN Sales.SalesOrderDetail AS sod
        ON p.ProductID = sod.ProductID
    GROUP BY pc.ProductCategoryID, pc.Name
)
SELECT
    CategoryName,
    TotalRevenue,
    CASE
        WHEN TotalRevenue > 1000000 THEN 'High Revenue'
        WHEN TotalRevenue >= 500000 THEN 'Medium Revenue'
        ELSE 'Low Revenue'
    END AS RevenueClassification
FROM CategoryRevenue
ORDER BY TotalRevenue DESC;
GO

/*==============================================================================
QUESTION 18 — Repeat category revenue classification using a separate CTE.

SOLUTION APPROACH:
- This is an alternative form of Question 17.
- The CTE calculates revenue by category.
- CASE classifies the calculated revenue.
- The output is ordered by category name.

IMPROVEMENT OVER THE ORIGINAL:
- Use the alias TotalRevenue instead of TotalExpense because LineTotal is
  being analyzed as revenue, not expense.
- This version also uses INNER JOINs, so categories without recorded sales
  will not appear. See Question 17 for the same inner-join scope.
==============================================================================*/
WITH CategoryClassification AS (
    SELECT
        pc.ProductCategoryID,
        pc.Name AS CategoryName,
        SUM(sod.LineTotal) AS TotalRevenue
    FROM Production.Product AS p
    INNER JOIN Sales.SalesOrderDetail AS sod
        ON sod.ProductID = p.ProductID
    INNER JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    INNER JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
    GROUP BY pc.ProductCategoryID, pc.Name
)
SELECT
    CategoryName,
    TotalRevenue,
    CASE
        WHEN TotalRevenue > 1000000 THEN 'High Revenue'
        WHEN TotalRevenue >= 500000 THEN 'Medium Revenue'
        ELSE 'Low Revenue'
    END AS RevenueClassification
FROM CategoryClassification
ORDER BY CategoryName;
GO
