CREATE DATABASE ecommerce_analytics;
USE ecommerce_analytics;

-- Customers who place orders
CREATE TABLE customers (
    customer_id   INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city          VARCHAR(50),
    signup_date   DATE
);

-- Sellers who list products
CREATE TABLE sellers (
    seller_id     INT PRIMARY KEY,
    seller_name   VARCHAR(100) NOT NULL,
    city          VARCHAR(50),
    rating        DECIMAL(2,1)
);

-- Products listed by sellers
CREATE TABLE products (
    product_id    INT PRIMARY KEY,
    product_name  VARCHAR(100) NOT NULL,
    category      VARCHAR(50),
    price         DECIMAL(10,2) NOT NULL,
    seller_id     INT,
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

-- Orders placed by customers
CREATE TABLE orders (
    order_id      INT PRIMARY KEY,
    customer_id   INT,
    order_date    DATE,
    status        VARCHAR(20),  -- e.g. delivered, shipped, cancelled, pending
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Line items within each order (an order can have multiple products)
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id      INT,
    product_id    INT,
    quantity      INT NOT NULL,
    unit_price    DECIMAL(10,2) NOT NULL, -- price at time of purchase
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Payments made against orders
CREATE TABLE payments (
    payment_id    INT PRIMARY KEY,
    order_id      INT,
    payment_type  VARCHAR(20), -- e.g. UPI, Credit Card, COD, Net Banking
    amount        DECIMAL(10,2),
    payment_date  DATE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
