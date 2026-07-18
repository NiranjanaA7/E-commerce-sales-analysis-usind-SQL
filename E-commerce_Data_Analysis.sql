-- E-commerce Data Analysis 
-- This script analyzes customer transactions and product sales data from an e-commerce platform.
-- The dataset was loaded using the Table Data Import Wizard in MySQL Workbench.

-- Create the ECommerce database
CREATE DATABASE ECommerceDB;

-- Use the ECommerce database
USE ECommerceDB;

-- Create Customers table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    gender ENUM('Male', 'Female', 'Non-binary', 'Other'),
    age INT,
    home_address VARCHAR(255),
    zip_code VARCHAR(20),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100)
);

-- Create Orders table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    payment DECIMAL(10, 2),
    order_date DATE,
    delivery_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Create Products table
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_type VARCHAR(100),
    product_name VARCHAR(100),
    size VARCHAR(50),
    colour VARCHAR(50),
    price DECIMAL(10, 2),
    quantity INT,
    description TEXT
);

-- Create Sales table
CREATE TABLE Sales (
    sales_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    price_per_unit DECIMAL(10, 2),
    quantity INT,
    total_price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Check the first 10 records in each table (optional for initial testing)
SELECT * FROM Customers LIMIT 10;
SELECT * FROM Products LIMIT 10;
SELECT * FROM Orders LIMIT 10;
SELECT * FROM Sales LIMIT 10;


-- 1. Total Sales by Product
-- Identify which products generate the most revenue.
SELECT p.product_name, SUM(s.total_price) AS total_sales
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC;

-- 2. Find Customers by Gender
-- Understand the gender distribution of customers for targeted marketing.
SELECT gender, COUNT(*) AS customer_count
FROM Customers
GROUP BY gender;

-- 3. Sales by Month
-- Track sales performance over time to identify trends.
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(s.total_price) AS total_sales
FROM Sales s
JOIN Orders o ON s.order_id = o.order_id
GROUP BY month
ORDER BY month;

-- 4. Top 5 Customers by Total Payment
-- Identify top customers for loyalty programs or targeted offers.
SELECT c.customer_name, SUM(o.payment) AS total_payment
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY total_payment DESC
LIMIT 5;

-- 5. Customers with No Recent Orders
-- Identify inactive customers for re-engagement campaigns.
SELECT c.customer_name, MAX(o.order_date) AS last_order_date
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name
HAVING MAX(o.order_date) < DATE_SUB(CURDATE(), INTERVAL 6 MONTH);

-- 6. Lifetime Value of Customers
-- Determine the lifetime value of customers to assess overall profitability.
SELECT c.customer_name, SUM(s.total_price) AS lifetime_value
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Sales s ON o.order_id = s.order_id
GROUP BY c.customer_name
ORDER BY lifetime_value DESC;

-- 7. Customer Segmentation Based on Spending
-- Categorize customers into spending segments for targeted marketing.
WITH CustomerSpending AS (
    SELECT c.customer_id, c.customer_name, SUM(s.total_price) AS total_spending
    FROM Customers c
    JOIN Orders o ON c.customer_id = o.customer_id
    JOIN Sales s ON o.order_id = s.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, total_spending,
       RANK() OVER (ORDER BY total_spending DESC) AS spending_rank,
       CASE
           WHEN total_spending > 3000 THEN 'High Spender'
           WHEN total_spending BETWEEN 1000 AND 3000 THEN 'Medium Spender'
           ELSE 'Low Spender'
       END AS spending_category
FROM CustomerSpending;
/*====================================
 SQL VIEWS
====================================*/

-- View 1 : Monthly Sales
CREATE VIEW vw_monthly_sales AS
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    SUM(s.total_price) AS total_revenue
FROM Orders o
JOIN Sales s
ON o.order_id = s.order_id
GROUP BY month;


-- View 2 : Customer Summary
CREATE VIEW vw_customer_summary AS
SELECT
    c.customer_id,
    c.customer_name,
    c.state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(s.total_price) AS total_revenue
FROM Customers c
JOIN Orders o
ON c.customer_id = o.customer_id
JOIN Sales s
ON o.order_id = s.order_id
GROUP BY
    c.customer_id,
    c.customer_name,
    c.state;


-- View 3 : Product Summary
CREATE VIEW vw_product_summary AS
SELECT
    p.product_id,
    p.product_name,
    p.product_type,
    SUM(s.quantity) AS quantity_sold,
    SUM(s.total_price) AS total_revenue
FROM Products p
JOIN Sales s
ON p.product_id = s.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.product_type;


-- View 4 : KPI Summary
CREATE VIEW vw_kpi_summary AS
SELECT
    SUM(payment) AS total_revenue,
    COUNT(order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(AVG(payment),2) AS average_order_value
FROM Orders; 

-- Q8. Running Revenue

SELECT
    month,
    total_revenue,
    SUM(total_revenue)
    OVER(ORDER BY month) AS running_revenue
FROM vw_monthly_sales;

-- Q9. Month over Month Growth

SELECT
    month,
    total_revenue,
    LAG(total_revenue)
    OVER(ORDER BY month) AS previous_month,
    total_revenue -
    LAG(total_revenue)
    OVER(ORDER BY month) AS revenue_change
FROM vw_monthly_sales;

-- Q10. Top Customer in Each State

SELECT *
FROM
(
    SELECT
        state,
        customer_name,
        total_revenue,
        ROW_NUMBER()
        OVER(
            PARTITION BY state
            ORDER BY total_revenue DESC
        ) AS rn

    FROM vw_customer_summary

) t

WHERE rn = 1;

-- Q11. Product Ranking

SELECT
    product_name,
    total_revenue,

    DENSE_RANK()
    OVER(
        ORDER BY total_revenue DESC
    ) AS product_rank

FROM vw_product_summary;

-- Q12. Revenue by Product Category

SELECT
    product_type,
    SUM(total_revenue) AS category_revenue

FROM vw_product_summary

GROUP BY product_type

ORDER BY category_revenue DESC;

-- Q13. KPI Summary

SELECT *
FROM vw_kpi_summary;

SHOW FULL TABLES
WHERE Table_type='VIEW';
