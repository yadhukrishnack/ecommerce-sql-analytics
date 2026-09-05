-- ============================================
-- BEGINNER QUERIES — SELECT, WHERE, ORDER BY, LIMIT
-- ============================================
USE ecommerce_analytics;

-- Q1: List all customers from a specific city (example: Kochi)
SELECT customer_id, customer_name, city, signup_date
FROM customers
WHERE city = 'Kochi';

-- Q2: Show all orders placed in the last 30 days
SELECT order_id, customer_id, order_date, status
FROM orders
WHERE order_date >= CURDATE() - INTERVAL 30 DAY
ORDER BY order_date DESC;

-- Q3: Find the 10 most expensive products
SELECT product_id, product_name, category, price
FROM products
ORDER BY price DESC
LIMIT 10;

-- Q4: List all orders with status = 'delivered'
SELECT order_id, customer_id, order_date, status
FROM orders
WHERE status = 'delivered'
ORDER BY order_date;

-- Q5: Find customers who signed up in 2025
SELECT customer_id, customer_name, city, signup_date
FROM customers
WHERE YEAR(signup_date) = 2025
ORDER BY signup_date;
