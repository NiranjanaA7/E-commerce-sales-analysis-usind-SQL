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

-- 3. Average Age of Customers
-- Analyze the average age of customers to tailor marketing strategies.
SELECT AVG(age) AS average_age FROM Customers;

-- 4. Sales by Month
-- Track sales performance over time to identify trends.
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(s.total_price) AS total_sales
FROM Sales s
JOIN Orders o ON s.order_id = o.order_id
GROUP BY month
ORDER BY month;

-- 5. Top 5 Customers by Total Payment
-- Identify top customers for loyalty programs or targeted offers.
SELECT c.customer_name, SUM(o.payment) AS total_payment
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY total_payment DESC
LIMIT 5;

-- 6. Customers with No Recent Orders
-- Identify inactive customers for re-engagement campaigns.
SELECT c.customer_name, MAX(o.order_date) AS last_order_date
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name
HAVING MAX(o.order_date) < DATE_SUB(CURDATE(), INTERVAL 6 MONTH);

-- 7. Lifetime Value of Customers
-- Determine the lifetime value of customers to assess overall profitability.
SELECT c.customer_name, SUM(s.total_price) AS lifetime_value
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Sales s ON o.order_id = s.order_id
GROUP BY c.customer_name
ORDER BY lifetime_value DESC;

-- 8. Customer Segmentation Based on Spending
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
