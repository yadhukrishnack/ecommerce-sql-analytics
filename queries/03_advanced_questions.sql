-- ============================================
-- ADVANCED QUERIES — Subqueries, CTEs, Window Functions, Views, Stored Procedures
-- ============================================
USE ecommerce_analytics;

-- Q1: Rank products by total revenue within each category
--     using DENSE_RANK()
SELECT category, product_name, total_revenue,
       DENSE_RANK() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS category_rank
FROM (
    SELECT p.category, p.product_name,
           SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.category, p.product_name
) AS product_totals
ORDER BY category, category_rank;

-- Q2: Find customers who spent more than the average customer spend
--     (subquery in WHERE clause)
SELECT customer_id, customer_name, total_spent
FROM (
    SELECT c.customer_id, c.customer_name, SUM(pay.amount) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments pay ON o.order_id = pay.order_id
    GROUP BY c.customer_id, c.customer_name
) AS customer_spend
WHERE total_spent > (
    SELECT AVG(total_spent) FROM (
        SELECT SUM(pay.amount) AS total_spent
        FROM orders o
        JOIN payments pay ON o.order_id = pay.order_id
        GROUP BY o.customer_id
    ) AS avg_calc
)
ORDER BY total_spent DESC;

-- Q3: Identify repeat customers using GROUP BY + HAVING
-- Note: the original guide's threshold ("more than 20 orders") assumes a
-- dataset far larger than any single portfolio project would realistically
-- need. With 320 orders across 120 customers, "more than 3 orders" identifies
-- a meaningful top segment (35 customers) -- scale the threshold with your
-- own data volume rather than copying a fixed number.
SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS num_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 3
ORDER BY num_orders DESC;

-- Q4: Monthly sales trend using a CTE (bonus: time-based trend analysis)
WITH monthly_sales AS (
    SELECT DATE_FORMAT(payment_date, '%Y-%m') AS sales_month,
           SUM(amount) AS revenue
    FROM payments
    GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
)
SELECT sales_month, revenue,
       LAG(revenue) OVER (ORDER BY sales_month) AS prev_month_revenue,
       ROUND(
         (revenue - LAG(revenue) OVER (ORDER BY sales_month))
         / LAG(revenue) OVER (ORDER BY sales_month) * 100, 1
       ) AS mom_growth_pct
FROM monthly_sales
ORDER BY sales_month;

-- Q5: Create a view called monthly_sales_summary that a dashboard tool
--     could read directly
CREATE OR REPLACE VIEW monthly_sales_summary AS
SELECT DATE_FORMAT(pay.payment_date, '%Y-%m') AS sales_month,
       COUNT(DISTINCT o.order_id)             AS total_orders,
       SUM(pay.amount)                        AS total_revenue,
       ROUND(AVG(pay.amount), 2)              AS avg_order_value
FROM orders o
JOIN payments pay ON o.order_id = pay.order_id
GROUP BY DATE_FORMAT(pay.payment_date, '%Y-%m');

-- Usage:
-- SELECT * FROM monthly_sales_summary ORDER BY sales_month;

-- Q6: Stored procedure get_customer_history(customer_id) that returns
--     a customer's full order history
DELIMITER //

CREATE PROCEDURE get_customer_history(IN cust_id INT)
BEGIN
    SELECT o.order_id,
           o.order_date,
           o.status,
           p.product_name,
           oi.quantity,
           oi.unit_price,
           (oi.quantity * oi.unit_price) AS line_total
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.customer_id = cust_id
    ORDER BY o.order_date;
END //

DELIMITER ;

-- Usage:
-- CALL get_customer_history(1);
