-- Delete old database so we can start fresh without conflicts
DROP DATABASE IF EXISTS ecommerce_project;

-- Allow MySQL to load CSV files from local system
SET GLOBAL local_infile = 1;

-- Create project database
CREATE DATABASE IF NOT EXISTS ecommerce_project;

-- Use the project database
USE ecommerce_project;

-- Raw table to store CSV data exactly as it comes (no cleaning yet)
CREATE TABLE orders_raw (
    InvoiceNo        VARCHAR(20),
    StockCode        VARCHAR(20),
    Description      VARCHAR(255),
    Quantity_raw     VARCHAR(50),
    InvoiceDate_raw  VARCHAR(50),
    UnitPrice_raw    VARCHAR(50),
    CustomerID_raw   VARCHAR(50),
    Country_raw      VARCHAR(50)
) ENGINE = InnoDB;

-- Load CSV file into raw table
LOAD DATA LOCAL INFILE 'C:/Users/HP/Documents/INTERACTIVEWEBSITE/SQL/orders.csv'
INTO TABLE orders_raw
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    InvoiceNo,
    StockCode,
    Description,
    Quantity_raw,
    InvoiceDate_raw,
    UnitPrice_raw,
    CustomerID_raw,
    Country_raw
);

-- Check total rows loaded from CSV
SELECT COUNT(*) AS raw_row_count
FROM orders_raw;

-- Preview raw data
SELECT *
FROM orders_raw
LIMIT 10;

-- Check missing values in important columns
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN Quantity_raw    IS NULL OR Quantity_raw    = '' THEN 1 ELSE 0 END) AS missing_quantity,
    SUM(CASE WHEN InvoiceDate_raw IS NULL OR InvoiceDate_raw = '' THEN 1 ELSE 0 END) AS missing_date,
    SUM(CASE WHEN UnitPrice_raw   IS NULL OR UnitPrice_raw   = '' THEN 1 ELSE 0 END) AS missing_price,
    SUM(CASE WHEN CustomerID_raw  IS NULL OR CustomerID_raw  = '' THEN 1 ELSE 0 END) AS missing_customer
FROM orders_raw;

-- Count number of rows per country
SELECT 
    Country_raw, 
    COUNT(*) AS rows_per_country
FROM orders_raw
GROUP BY Country_raw
ORDER BY rows_per_country DESC;

-- Identify negative, zero quantity and invalid price values
SELECT
    SUM(CASE WHEN CAST(Quantity_raw AS SIGNED) < 0 THEN 1 ELSE 0 END) AS negative_qty_rows,
    SUM(CASE WHEN CAST(Quantity_raw AS SIGNED) = 0 THEN 1 ELSE 0 END) AS zero_qty_rows,
    SUM(CASE WHEN CAST(UnitPrice_raw AS DECIMAL(10,4)) <= 0 THEN 1 ELSE 0 END) AS nonpositive_price_rows
FROM orders_raw;

-- Create clean table with proper data types and business logic
CREATE TABLE orders_clean AS
SELECT
    InvoiceNo,
    StockCode,
    TRIM(Description) AS Description,
    CAST(Quantity_raw AS SIGNED) AS Quantity,

    -- Convert mixed date formats into proper DATETIME
    CASE
        WHEN CAST(SUBSTRING_INDEX(REPLACE(InvoiceDate_raw, '-', '/'), '/', 1) AS UNSIGNED) > 12 THEN
            STR_TO_DATE(REPLACE(InvoiceDate_raw, '-', '/'), '%d/%m/%Y %H:%i')
        ELSE
            STR_TO_DATE(REPLACE(InvoiceDate_raw, '-', '/'), '%m/%d/%Y %H:%i')
    END AS InvoiceDate,

    CAST(UnitPrice_raw AS DECIMAL(10,4)) AS UnitPrice,
    CAST(NULLIF(CustomerID_raw, '') AS UNSIGNED) AS CustomerID,
    TRIM(Country_raw) AS Country,

    -- Calculate revenue per row
    CAST(Quantity_raw AS SIGNED) * CAST(UnitPrice_raw AS DECIMAL(10,4)) AS Revenue,

    -- Flag rows where quantity is negative (returns)
    CASE
        WHEN CAST(Quantity_raw AS SIGNED) < 0 THEN 1
        ELSE 0
    END AS is_return
FROM orders_raw
WHERE
    -- Keep only rows with valid dates
    (
        CASE
            WHEN CAST(SUBSTRING_INDEX(REPLACE(InvoiceDate_raw, '-', '/'), '/', 1) AS UNSIGNED) > 12 THEN
                STR_TO_DATE(REPLACE(InvoiceDate_raw, '-', '/'), '%d/%m/%Y %H:%i')
            ELSE
                STR_TO_DATE(REPLACE(InvoiceDate_raw, '-', '/'), '%m/%d/%Y %H:%i')
        END
    ) IS NOT NULL
    AND Quantity_raw  IS NOT NULL AND Quantity_raw  <> ''
    AND UnitPrice_raw IS NOT NULL AND UnitPrice_raw <> ''
    AND CAST(Quantity_raw AS SIGNED) <> 0
    AND CAST(UnitPrice_raw AS DECIMAL(10,4)) > 0;

-- Count rows after cleaning
SELECT COUNT(*) AS clean_row_count
FROM orders_clean;

-- Preview cleaned data
SELECT *
FROM orders_clean
LIMIT 10;

-- Compare raw vs clean data and total revenue
SELECT 
    'RAW' AS table_name,
    COUNT(*) AS row_count,
    NULL AS total_revenue
FROM orders_raw
UNION ALL
SELECT
    'CLEAN' AS table_name,
    COUNT(*) AS row_count,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM orders_clean;

-- Show tables in database
SHOW TABLES;

-- Total number of cleaned rows
SELECT COUNT(*) AS total_rows
FROM orders_clean;

-- Count unique customers
SELECT COUNT(DISTINCT CustomerID) AS unique_customers
FROM orders_clean
WHERE CustomerID IS NOT NULL;

-- Count unique products
SELECT COUNT(DISTINCT StockCode) AS unique_products
FROM orders_clean;

-- Total revenue from clean data
SELECT ROUND(SUM(Revenue), 2) AS total_revenue
FROM orders_clean;

-- Sales date range
SELECT
    MIN(InvoiceDate) AS first_date,
    MAX(InvoiceDate) AS last_date
FROM orders_clean;

-- Total number of orders
SELECT COUNT(DISTINCT InvoiceNo) AS total_orders
FROM orders_clean;

-- Average order value
SELECT
    ROUND(SUM(Revenue) / COUNT(DISTINCT InvoiceNo), 2) AS avg_order_value
FROM orders_clean;

-- Revenue by country
SELECT
    Country,
    ROUND(SUM(Revenue), 2) AS revenue
FROM orders_clean
GROUP BY Country
ORDER BY revenue DESC;

-- Top 10 countries with percentage contribution
SELECT
    c.Country,
    ROUND(c.revenue, 2) AS revenue,
    ROUND(100 * c.revenue / t.total_revenue, 2) AS pct_of_total
FROM (
    SELECT Country, SUM(Revenue) AS revenue
    FROM orders_clean
    GROUP BY Country
) AS c
CROSS JOIN (
    SELECT SUM(Revenue) AS total_revenue
    FROM orders_clean
) AS t
ORDER BY c.revenue DESC
LIMIT 10;

-- Monthly revenue trend
SELECT
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS month_year,
    ROUND(SUM(Revenue), 2) AS revenue,
    COUNT(DISTINCT InvoiceNo) AS num_orders
FROM orders_clean
GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
ORDER BY DATE_FORMAT(InvoiceDate, '%Y-%m');

-- Daily revenue (last 30 days)
SELECT
    DATE(InvoiceDate) AS sales_date,
    ROUND(SUM(Revenue), 2) AS revenue
FROM orders_clean
GROUP BY DATE(InvoiceDate)
ORDER BY sales_date DESC
LIMIT 30;

-- Revenue by hour of day
SELECT
    HOUR(InvoiceDate) AS hour_of_day,
    ROUND(SUM(Revenue), 2) AS revenue,
    COUNT(DISTINCT InvoiceNo) AS num_orders
FROM orders_clean
GROUP BY HOUR(InvoiceDate)
ORDER BY revenue DESC;

-- Revenue by day of week
SELECT
    DAYNAME(InvoiceDate) AS day_of_week,
    ROUND(SUM(Revenue), 2) AS revenue,
    COUNT(DISTINCT InvoiceNo) AS num_orders
FROM orders_clean
GROUP BY DAYNAME(InvoiceDate)
ORDER BY revenue DESC;

-- Top 10 products by revenue
SELECT
    StockCode,
    Description,
    ROUND(SUM(Revenue), 2) AS revenue,
    SUM(Quantity) AS total_quantity
FROM orders_clean
GROUP BY StockCode, Description
ORDER BY revenue DESC
LIMIT 10;

-- Top 10 products by quantity sold
SELECT
    StockCode,
    Description,
    SUM(Quantity) AS total_quantity
FROM orders_clean
GROUP BY StockCode, Description
ORDER BY total_quantity DESC
LIMIT 10;

-- Products with highest return rate
SELECT
    StockCode,
    Description,
    COUNT(*) AS total_lines,
    SUM(is_return) AS total_returns,
    ROUND(100 * SUM(is_return) / COUNT(*), 2) AS return_rate_pct
FROM orders_clean
GROUP BY StockCode, Description
HAVING total_lines > 50
ORDER BY return_rate_pct DESC
LIMIT 15;

-- Top customers by total spend
SELECT
    CustomerID,
    ROUND(SUM(Revenue), 2) AS total_spent,
    COUNT(DISTINCT InvoiceNo) AS num_orders
FROM orders_clean
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY total_spent DESC
LIMIT 15;

-- Customers with highest order frequency
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS order_count,
    ROUND(SUM(Revenue), 2) AS total_spent
FROM orders_clean
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY order_count DESC
LIMIT 15;

-- One-time vs repeat customers
SELECT
    CASE 
        WHEN order_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS num_customers
FROM (
    SELECT CustomerID, COUNT(DISTINCT InvoiceNo) AS order_count
    FROM orders_clean
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
) AS t
GROUP BY customer_type;

-- Average items per order
SELECT
    ROUND(AVG(items_per_order), 2) AS avg_items_per_order
FROM (
    SELECT
        InvoiceNo,
        SUM(Quantity) AS items_per_order
    FROM orders_clean
    GROUP BY InvoiceNo
) AS t;

-- High value orders
SELECT
    InvoiceNo,
    CustomerID,
    ROUND(SUM(Revenue), 2) AS order_value
FROM orders_clean
GROUP BY InvoiceNo, CustomerID
HAVING order_value > 500
ORDER BY order_value DESC;

-- Net revenue and total returns value
SELECT
    ROUND(SUM(Revenue), 2) AS net_revenue_after_returns,
    ROUND(SUM(CASE WHEN is_return = 1 THEN Revenue ELSE 0 END), 2) AS total_return_value
FROM orders_clean;

-- Return impact by country
SELECT
    Country,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(CASE WHEN is_return = 1 THEN Revenue ELSE 0 END), 2) AS return_revenue,
    ROUND(
        100 * SUM(CASE WHEN is_return = 1 THEN Revenue ELSE 0 END) / SUM(Revenue),
        2
    ) AS return_pct
FROM orders_clean
GROUP BY Country
HAVING total_revenue > 5000
ORDER BY return_pct DESC;

-- Orders count by country
SELECT
    Country,
    COUNT(DISTINCT InvoiceNo) AS num_orders
FROM orders_clean
GROUP BY Country
ORDER BY num_orders DESC;

-- Average order value per country
SELECT
    Country,
    ROUND(SUM(Revenue) / COUNT(DISTINCT InvoiceNo), 2) AS avg_order_value,
    COUNT(DISTINCT InvoiceNo) AS num_orders
FROM orders_clean
GROUP BY Country
HAVING num_orders > 50
ORDER BY avg_order_value DESC;

-- Active customers per month
SELECT
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS month_year,
    COUNT(DISTINCT CustomerID) AS active_customers
FROM orders_clean
WHERE CustomerID IS NOT NULL
GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
ORDER BY DATE_FORMAT(InvoiceDate, '%Y-%m');

-- First purchase date per customer
SELECT
    CustomerID,
    MIN(InvoiceDate) AS first_purchase_date
FROM orders_clean
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY first_purchase_date;

-- Last purchase date per customer
SELECT
    CustomerID,
    MAX(InvoiceDate) AS last_purchase_date
FROM orders_clean
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY last_purchase_date DESC;

-- Customer tenure and total spend
SELECT
    CustomerID,
    MIN(InvoiceDate) AS first_purchase_date,
    MAX(InvoiceDate) AS last_purchase_date,
    DATEDIFF(MAX(InvoiceDate), MIN(InvoiceDate)) AS tenure_days,
    ROUND(SUM(Revenue), 2) AS total_spent
FROM orders_clean
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
HAVING tenure_days > 0
ORDER BY tenure_days DESC
LIMIT 20;

-- Top 10 most profitable days
SELECT
    DATE(InvoiceDate) AS sales_date,
    ROUND(SUM(Revenue), 2) AS revenue
FROM orders_clean
GROUP BY DATE(InvoiceDate)
ORDER BY revenue DESC
LIMIT 10;
