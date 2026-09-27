-- ============================================================
-- E-COMMERCE DATA WAREHOUSE
-- Basic Data + Analysis
-- ============================================================


-- ============================================================
-- 1. INSERT CUSTOMERS
-- ============================================================

INSERT INTO customers
    (first_name, last_name, email, phone, city, country)
VALUES
    ('Ahmed', 'Benali', 'ahmed.benali@gmail.com',
     '0612345678', 'Casablanca', 'Morocco'),

    ('Sara', 'Alaoui', 'sara.alaoui@gmail.com',
     '0623456789', 'Rabat', 'Morocco'),

    ('Youssef', 'Amrani', 'youssef.amrani@gmail.com',
     '0634567890', 'Marrakech', 'Morocco'),

    ('Salma', 'Idrissi', 'salma.idrissi@gmail.com',
     '0645678901', 'Tangier', 'Morocco'),

    ('Omar', 'Naciri', 'omar.naciri@gmail.com',
     '0656789012', 'Agadir', 'Morocco');


-- ============================================================
-- 2. CHECK CUSTOMERS
-- ============================================================

SELECT *
FROM customers;


-- ============================================================
-- 3. INSERT PRODUCTS
-- ============================================================

INSERT INTO products
    (product_name, category, price, stock_quantity)
VALUES
    ('Laptop Lenovo ThinkPad', 'Electronics', 8500.00, 20),
    ('Wireless Mouse', 'Electronics', 250.00, 100),
    ('Mechanical Keyboard', 'Electronics', 750.00, 50),
    ('Office Chair', 'Furniture', 1800.00, 30),
    ('USB-C Hub', 'Accessories', 450.00, 75),
    ('27 Inch Monitor', 'Electronics', 3200.00, 25);


-- ============================================================
-- 4. CHECK PRODUCTS
-- ============================================================

SELECT *
FROM products;


-- ============================================================
-- 5. INSERT ORDERS
-- ============================================================

INSERT INTO orders
    (customer_id, order_date, status)
VALUES
    (1, '2026-01-10', 'Delivered'),
    (2, '2026-01-15', 'Shipped'),
    (3, '2026-02-03', 'Delivered'),
    (4, '2026-02-10', 'Pending'),
    (5, '2026-02-18', 'Cancelled'),
    (1, '2026-03-01', 'Delivered'),
    (3, '2026-03-05', 'Shipped'),
    (2, '2026-03-12', 'Pending');


-- ============================================================
-- 6. CHECK ORDERS
-- ============================================================

SELECT *
FROM orders
ORDER BY order_id;


-- ============================================================
-- 7. JOIN ORDERS + CUSTOMERS
-- ============================================================

SELECT
    o.order_id,
    c.first_name,
    c.last_name,
    o.order_date,
    o.status
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
ORDER BY o.order_id;


-- ============================================================
-- 8. INSERT ORDER ITEMS
-- ============================================================

INSERT INTO order_items
    (order_id, product_id, quantity, unit_price)
VALUES
    (1, 1, 1, 8500.00),
    (1, 2, 2, 250.00),
    (1, 5, 1, 450.00),

    (2, 3, 1, 750.00),
    (2, 4, 1, 1800.00),

    (3, 1, 1, 8500.00),
    (3, 6, 2, 3200.00),

    (4, 2, 3, 250.00),
    (4, 5, 2, 450.00),

    (5, 4, 1, 1800.00),

    (6, 1, 1, 8500.00),
    (6, 3, 1, 750.00),

    (7, 6, 1, 3200.00),
    (7, 2, 1, 250.00),

    (8, 5, 2, 450.00);


-- ============================================================
-- 9. CHECK ORDER ITEMS
-- ============================================================

SELECT *
FROM order_items
ORDER BY order_id, order_item_id;


-- ============================================================
-- 10. COUNT ORDER ITEMS
-- ============================================================

SELECT COUNT(*) AS total_order_items
FROM order_items;


-- ============================================================
-- 11. ORDER DETAILS
-- ============================================================

SELECT
    o.order_id,
    c.first_name,
    c.last_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS total_price
FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN customers c
    ON o.customer_id = c.customer_id

JOIN products p
    ON oi.product_id = p.product_id

ORDER BY o.order_id;


-- ============================================================
-- 12. TOTAL REVENUE
-- ============================================================

SELECT
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

WHERE o.status <> 'Cancelled';


-- Expected:
-- 42150.00


-- ============================================================
-- 13. BEST-SELLING PRODUCTS
-- ============================================================

SELECT
    p.product_name,
    SUM(oi.quantity) AS units_sold

FROM order_items oi

JOIN products p
    ON oi.product_id = p.product_id

JOIN orders o
    ON oi.order_id = o.order_id

WHERE o.status <> 'Cancelled'

GROUP BY p.product_name

ORDER BY units_sold DESC;


-- ============================================================
-- 14. INSERT PAYMENTS
-- ============================================================

INSERT INTO payments
    (order_id, payment_method, amount, payment_date)
VALUES
    (1, 'Credit Card', 9450.00, '2026-01-10'),
    (2, 'PayPal', 2550.00, '2026-01-15'),
    (3, 'Credit Card', 14900.00, '2026-02-03'),
    (4, 'Cash on Delivery', 1650.00, '2026-02-10'),
    (5, 'Credit Card', 1800.00, '2026-02-18'),
    (6, 'Credit Card', 9250.00, '2026-03-01'),
    (7, 'PayPal', 3450.00, '2026-03-05'),
    (8, 'Cash on Delivery', 900.00, '2026-03-12');


-- ============================================================
-- 15. CHECK PAYMENTS
-- ============================================================

SELECT *
FROM payments
ORDER BY payment_id;


-- ============================================================
-- 16. INSERT SHIPMENTS
-- ============================================================

INSERT INTO shipments
    (order_id, carrier, tracking_number, shipped_date, delivery_date)
VALUES
    (1, 'DHL', 'DHL-MA-100001',
     '2026-01-11', '2026-01-14'),

    (2, 'Amana', 'AMA-MA-100002',
     '2026-01-16', NULL),

    (3, 'DHL', 'DHL-MA-100003',
     '2026-02-04', '2026-02-08'),

    (6, 'Amana', 'AMA-MA-100006',
     '2026-03-02', '2026-03-05'),

    (7, 'DHL', 'DHL-MA-100007',
     '2026-03-06', NULL);


-- ============================================================
-- 17. CHECK SHIPMENTS
-- ============================================================

SELECT *
FROM shipments
ORDER BY shipment_id;


-- ============================================================
-- 18. ORDERS + CUSTOMERS + PAYMENTS
-- ============================================================

SELECT
    o.order_id,
    c.first_name,
    c.last_name,
    o.order_date,
    o.status,
    p.payment_method,
    p.amount

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

JOIN payments p
    ON o.order_id = p.order_id

ORDER BY o.order_id;


-- ============================================================
-- 19. REVENUE BY PAYMENT METHOD
-- ============================================================

SELECT
    payment_method,
    SUM(amount) AS total_amount

FROM payments

GROUP BY payment_method

ORDER BY total_amount DESC;


-- ============================================================
-- 20. DATA QUALITY:
-- CANCELLED ORDERS WITH PAYMENTS
-- ============================================================

SELECT
    o.order_id,
    o.status,
    p.amount,
    p.payment_method

FROM orders o

JOIN payments p
    ON o.order_id = p.order_id

WHERE o.status = 'Cancelled';


-- ============================================================
-- 21. DATA QUALITY:
-- ORDERS WITHOUT SHIPMENTS
-- ============================================================

SELECT
    o.order_id,
    o.status

FROM orders o

LEFT JOIN shipments s
    ON o.order_id = s.order_id

WHERE s.shipment_id IS NULL;


-- ============================================================
-- 22. DATA QUALITY:
-- DELIVERED ORDERS WITHOUT SHIPMENTS
-- ============================================================

SELECT
    o.order_id,
    o.status

FROM orders o

LEFT JOIN shipments s
    ON o.order_id = s.order_id

WHERE o.status = 'Delivered'
  AND s.shipment_id IS NULL;


-- ============================================================
-- 23. DATA QUALITY:
-- INVALID QUANTITIES
-- ============================================================

SELECT *
FROM order_items
WHERE quantity <= 0;


-- ============================================================
-- 24. DATA QUALITY:
-- NEGATIVE PRODUCT PRICES
-- ============================================================

SELECT *
FROM products
WHERE price < 0;