# Query Results

This folder contains CSV exports generated from SQL queries executed against the AdventureWorks2019 database.

The files provide a way to inspect query outputs without having to execute every SQL script locally.

## Main Analysis Results

The following CSV files correspond to the individual SQL analysis scripts in the `sql/` directory.

| CSV File | Analysis |
|---|---|
| `01_overall_sales_kpis.csv` | Overall sales KPIs |
| `02_product_quantity_sold.csv` | Product-wise quantity sold |
| `03_category_revenue_classification.csv` | Revenue classification by product category |
| `04_top_products_by_revenue.csv` | Top products ranked by revenue |
| `05_customer_sales_contribution.csv` | Customer sales contribution |
| `06_products_without_recorded_sales.csv` | Products without recorded sales-order details |

## Practice Query Exports

Files beginning with `00_Overall_queries` contain additional exports from the consolidated SQL practice queries.

These files are retained separately from the six main analysis outputs. Refer to `sql/00_Overall_queries.sql` to identify the corresponding queries before interpreting individual exports.

## How to Use These Results

1. Open a CSV file in Excel, Power BI, or another compatible data-analysis tool.
2. Review the column names and returned records.
3. Refer to the corresponding SQL script to understand the query logic, joins, filters, aggregations, and sorting.
4. Re-run the query against your own AdventureWorks2019 database to reproduce the results.

## Important Notes

- Results depend on the database contents and the SQL query used to generate each export.
- Sales revenue, order totals, and quantities represent different measures; consult the relevant SQL script before comparing them.
- CSV files are snapshots of query outputs, not live connections to SQL Server.
- File names describe their intended purpose. Always verify the query and column headers when matching additional practice exports to their source queries.