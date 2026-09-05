-- ============================================
-- INTERMEDIATE QUERIES — JOINs, GROUP BY, HAVING, Aggregates
-- ============================================
USE ecommerce_analytics;

-- Q1: What is the total revenue generated so far?
-- (Revenue = money actually collected via successful payments)
SELECT SUM(amount) AS total_revenue
FROM payments;

-- Q2: Which product category has sold the most units?
SELECT p.category, SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY units_sold DESC
LIMIT 1;

-- Q3: List the top 5 customers by total amount spent
SELECT c.customer_id, c.customer_name, SUM(pay.amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments pay ON o.order_id = pay.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC
LIMIT 5;

-- Q4: Which sellers have generated more than a set revenue threshold? (HAVING)
-- Threshold example: 5000
SELECT s.seller_id, s.seller_name, SUM(oi.quantity * oi.unit_price) AS seller_revenue
FROM sellers s
JOIN products p ON s.seller_id = p.seller_id
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY s.seller_id, s.seller_name
HAVING SUM(oi.quantity * oi.unit_price) > 5000
ORDER BY seller_revenue DESC;

-- Q5: What is the average order value per city?
SELECT c.city, ROUND(AVG(pay.amount), 2) AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments pay ON o.order_id = pay.order_id
GROUP BY c.city
ORDER BY avg_order_value DESC;

-- Q6: How many orders did each payment type handle,
--     and what's the average payment value per type?
SELECT payment_type,
       COUNT(*) AS num_orders,
       ROUND(AVG(amount), 2) AS avg_payment_value
FROM payments
GROUP BY payment_type
ORDER BY num_orders DESC;
