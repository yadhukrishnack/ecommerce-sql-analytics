# E-Commerce Sales & Customer Analytics (SQL / MySQL)

SQL analysis of a simulated e-commerce platform's sales and customer data using MySQL —
covering everything from basic filtering to window functions, CTEs, views, and a stored procedure.

## Tools Used
- **MySQL 8.0** (MySQL Workbench)
- SQL only — no external BI tool used for this version

## Dataset
Custom-built relational dataset (not from Kaggle). I designed the schema myself to
demonstrate database design skills, not just querying — see `schema/create_tables.sql`.
Sample data (`data/sample_data.sql`) includes **120 customers, 18 sellers, 60 products,
320 orders, 804 order line items, and 277 payments — 1,599 rows in total.**
Payments exist only for orders with status `delivered` or `shipped`; `cancelled`
and `pending` orders intentionally have none, which mirrors real transaction data
and makes JOIN vs. LEFT JOIN behavior meaningfully different across queries.

## Schema / ER Structure

```
customers (customer_id PK)
sellers   (seller_id PK)
products  (product_id PK, seller_id FK -> sellers)
orders    (order_id PK, customer_id FK -> customers)
order_items (order_item_id PK, order_id FK -> orders, product_id FK -> products)
payments  (payment_id PK, order_id FK -> orders)
```

`orders` → `order_items` → `products` → `sellers`, with `payments` attached to `orders`.
The `order_items` table lets a single order contain multiple products with quantities —
needed to accurately calculate revenue, units sold, and top products.



## Repository Structure
```
ecommerce-sql-analytics/
├── README.md
├── schema/
│   └── create_tables.sql
├── data/
│   └── sample_data.sql
├── queries/
│   ├── 01_beginner_questions.sql
│   ├── 02_intermediate_questions.sql
│   └── 03_advanced_questions.sql
└── screenshots/
    └── (query result screenshots, ER diagram)
```

## How to Run
1. Run `schema/create_tables.sql` to create the database and tables.
2. Run `data/sample_data.sql` to populate them.
3. Run any file in `queries/` to see the analysis.

## Key Business Questions Answered

**1. What is the total revenue generated so far?**
```sql
SELECT SUM(amount) AS total_revenue FROM payments;
```

**2. Who are the top 5 customers by total amount spent?**
```sql
SELECT c.customer_id, c.customer_name, SUM(pay.amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments pay ON o.order_id = pay.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC
LIMIT 5;
```

**3. Rank products by revenue within each category (window function)**
```sql
SELECT category, product_name, total_revenue,
       DENSE_RANK() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS category_rank
FROM ( ... ) AS product_totals;
```

**4. Monthly sales trend with month-over-month growth (CTE + LAG)**
```sql
WITH monthly_sales AS (
    SELECT DATE_FORMAT(payment_date, '%Y-%m') AS sales_month, SUM(amount) AS revenue
    FROM payments GROUP BY sales_month
)
SELECT sales_month, revenue,
       LAG(revenue) OVER (ORDER BY sales_month) AS prev_month_revenue
FROM monthly_sales;
```

**5. A reusable view for dashboards: `monthly_sales_summary`**
```sql
CREATE OR REPLACE VIEW monthly_sales_summary AS
SELECT DATE_FORMAT(pay.payment_date, '%Y-%m') AS sales_month,
       COUNT(DISTINCT o.order_id) AS total_orders,
       SUM(pay.amount) AS total_revenue,
       ROUND(AVG(pay.amount), 2) AS avg_order_value
FROM orders o
JOIN payments pay ON o.order_id = pay.order_id
GROUP BY sales_month;
```


## What I Learned
Practiced designing a normalized relational schema from scratch (including a
line-items table to handle multi-product orders correctly), used window functions
(`DENSE_RANK`, `LAG`) for ranking and trend analysis, wrote CTEs for readable
multi-step aggregation, and built a view and a stored procedure so the same
queries could be reused by a dashboard tool or application layer.

## Full Query List
See `queries/01_beginner_questions.sql`, `02_intermediate_questions.sql`, and
`03_advanced_questions.sql` for all 17 solved queries, each with a comment
describing the business question it answers.
