-- ============================================================
-- E-COMMERCE DATA WAREHOUSE
-- Warehouse Analytics
-- ============================================================
--
-- Purpose:
-- Analyze business performance using the dimensional warehouse.
--
-- Main warehouse objects:
--   dw.dim_customer
--   dw.dim_product
--   dw.dim_date
--   dw.dim_payment_method
--   dw.dim_shipping
--   dw.fact_sales
--   dw.fact_payments
--   dw.fact_shipping
--
-- fact_sales grain:
--   One row per order item
-- ============================================================


-- ============================================================
-- 1. OVERALL SALES PERFORMANCE
-- ============================================================

SELECT
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_units_sold,
    COUNT(DISTINCT order_id) AS total_orders
FROM dw.fact_sales;


-- ============================================================
-- 2. MONTHLY SALES
-- ============================================================

SELECT
    d.year,
    d.month,
    d.month_name,
    SUM(f.sales_amount) AS total_sales,
    SUM(f.quantity) AS total_units_sold,
    COUNT(DISTINCT f.order_id) AS total_orders
FROM dw.fact_sales f
JOIN dw.dim_date d
    ON f.order_date_key = d.date_key
GROUP BY
    d.year,
    d.month,
    d.month_name
ORDER BY
    d.year,
    d.month;


-- ============================================================
-- 3. SALES BY PRODUCT
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(f.quantity) AS units_sold,
    SUM(f.sales_amount) AS total_sales
FROM dw.fact_sales f
JOIN dw.dim_product p
    ON f.product_key = p.product_key
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY
    total_sales DESC;


-- ============================================================
-- 4. SALES BY PRODUCT CATEGORY
-- ============================================================

SELECT
    p.category,
    SUM(f.quantity) AS units_sold,
    SUM(f.sales_amount) AS total_sales,
    COUNT(DISTINCT f.order_id) AS total_orders
FROM dw.fact_sales f
JOIN dw.dim_product p
    ON f.product_key = p.product_key
GROUP BY
    p.category
ORDER BY
    total_sales DESC;


-- ============================================================
-- 5. TOP CUSTOMERS BY SALES
-- ============================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.city,
    c.country,
    COUNT(DISTINCT f.order_id) AS total_orders,
    SUM(f.quantity) AS units_purchased,
    SUM(f.sales_amount) AS total_sales
FROM dw.fact_sales f
JOIN dw.dim_customer c
    ON f.customer_key = c.customer_key
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.city,
    c.country
ORDER BY
    total_sales DESC;


-- ============================================================
-- 6. SALES BY CUSTOMER CITY
-- ============================================================

SELECT
    c.city,
    c.country,
    COUNT(DISTINCT f.order_id) AS total_orders,
    SUM(f.quantity) AS units_sold,
    SUM(f.sales_amount) AS total_sales
FROM dw.fact_sales f
JOIN dw.dim_customer c
    ON f.customer_key = c.customer_key
GROUP BY
    c.city,
    c.country
ORDER BY
    total_sales DESC;


-- ============================================================
-- 7. AVERAGE ORDER VALUE
-- ============================================================

SELECT
    ROUND(
        SUM(sales_amount) / COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM dw.fact_sales;


-- ============================================================
-- 8. TOP PRODUCTS BY UNITS SOLD
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(f.quantity) AS units_sold
FROM dw.fact_sales f
JOIN dw.dim_product p
    ON f.product_key = p.product_key
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY
    units_sold DESC;


-- ============================================================
-- 9. SALES BY PAYMENT METHOD
-- ============================================================

SELECT
    pm.payment_method,
    COUNT(*) AS payment_count,
    SUM(fp.amount) AS total_payment_amount
FROM dw.fact_payments fp
JOIN dw.dim_payment_method pm
    ON fp.payment_method_key = pm.payment_method_key
GROUP BY
    pm.payment_method
ORDER BY
    total_payment_amount DESC;


-- ============================================================
-- 10. PAYMENT ANALYSIS
-- ============================================================

SELECT
    pm.payment_method,
    COUNT(*) AS number_of_payments,
    SUM(fp.amount) AS total_amount,
    ROUND(AVG(fp.amount), 2) AS average_payment
FROM dw.fact_payments fp
JOIN dw.dim_payment_method pm
    ON fp.payment_method_key = pm.payment_method_key
GROUP BY
    pm.payment_method
ORDER BY
    total_amount DESC;


-- ============================================================
-- 11. SHIPPING PERFORMANCE
-- ============================================================

SELECT
    s.carrier,
    COUNT(*) AS total_shipments,
    COUNT(s.delivery_date_key) AS delivered_shipments,
    ROUND(AVG(s.delivery_days), 2) AS average_delivery_days
FROM dw.fact_shipping s
JOIN dw.dim_shipping ds
    ON s.shipping_key = ds.shipping_key
GROUP BY
    s.carrier
ORDER BY
    average_delivery_days;


-- ============================================================
-- 12. SHIPPING DETAILS
-- ============================================================

SELECT
    s.shipment_id,
    s.order_id,
    ds.carrier,
    ds.tracking_number,
    s.shipped_date_key,
    s.delivery_date_key,
    s.delivery_days
FROM dw.fact_shipping s
JOIN dw.dim_shipping ds
    ON s.shipping_key = ds.shipping_key
ORDER BY
    s.order_id;


-- ============================================================
-- 13. MONTHLY SALES TREND
-- ============================================================

SELECT
    d.year,
    d.month,
    d.month_name,
    SUM(f.sales_amount) AS total_sales
FROM dw.fact_sales f
JOIN dw.dim_date d
    ON f.order_date_key = d.date_key
GROUP BY
    d.year,
    d.month,
    d.month_name
ORDER BY
    d.year,
    d.month;


-- ============================================================
-- 14. PRODUCT REVENUE RANKING
-- ============================================================

SELECT
    p.product_name,
    p.category,
    SUM(f.sales_amount) AS total_sales,
    RANK() OVER (
        ORDER BY SUM(f.sales_amount) DESC
    ) AS revenue_rank
FROM dw.fact_sales f
JOIN dw.dim_product p
    ON f.product_key = p.product_key
GROUP BY
    p.product_name,
    p.category
ORDER BY
    revenue_rank;


-- ============================================================
-- 15. CUSTOMER REVENUE RANKING
-- ============================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_sales,
    RANK() OVER (
        ORDER BY SUM(f.sales_amount) DESC
    ) AS customer_rank
FROM dw.fact_sales f
JOIN dw.dim_customer c
    ON f.customer_key = c.customer_key
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY
    customer_rank;


-- ============================================================
-- 16. SALES BY QUARTER
-- ============================================================

SELECT
    d.year,
    d.quarter,
    SUM(f.sales_amount) AS total_sales,
    SUM(f.quantity) AS units_sold,
    COUNT(DISTINCT f.order_id) AS total_orders
FROM dw.fact_sales f
JOIN dw.dim_date d
    ON f.order_date_key = d.date_key
GROUP BY
    d.year,
    d.quarter
ORDER BY
    d.year,
    d.quarter;


-- ============================================================
-- 17. DAILY SALES
-- ============================================================

SELECT
    d.full_date,
    SUM(f.sales_amount) AS total_sales,
    SUM(f.quantity) AS units_sold,
    COUNT(DISTINCT f.order_id) AS total_orders
FROM dw.fact_sales f
JOIN dw.dim_date d
    ON f.order_date_key = d.date_key
GROUP BY
    d.full_date
ORDER BY
    d.full_date;


-- ============================================================
-- 18. SALES BY COUNTRY
-- ============================================================

SELECT
    c.country,
    COUNT(DISTINCT f.order_id) AS total_orders,
    SUM(f.quantity) AS units_sold,
    SUM(f.sales_amount) AS total_sales
FROM dw.fact_sales f
JOIN dw.dim_customer c
    ON f.customer_key = c.customer_key
GROUP BY
    c.country
ORDER BY
    total_sales DESC;


-- ============================================================
-- 19. DATA QUALITY:
-- ORPHAN CUSTOMER KEYS
-- ============================================================

SELECT
    COUNT(*) AS orphan_customer_records
FROM dw.fact_sales f
LEFT JOIN dw.dim_customer c
    ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;


-- ============================================================
-- 20. DATA QUALITY:
-- ORPHAN PRODUCT KEYS
-- ============================================================

SELECT
    COUNT(*) AS orphan_product_records
FROM dw.fact_sales f
LEFT JOIN dw.dim_product p
    ON f.product_key = p.product_key
WHERE p.product_key IS NULL;


-- ============================================================
-- 21. DATA QUALITY:
-- ORPHAN DATE KEYS
-- ============================================================

SELECT
    COUNT(*) AS orphan_date_records
FROM dw.fact_sales f
LEFT JOIN dw.dim_date d
    ON f.order_date_key = d.date_key
WHERE d.date_key IS NULL;


-- ============================================================
-- 22. DATA QUALITY:
-- INVALID SALES AMOUNTS
-- ============================================================

SELECT
    COUNT(*) AS invalid_sales_records
FROM dw.fact_sales
WHERE quantity <= 0
   OR unit_price < 0
   OR sales_amount < 0;


-- ============================================================
-- 23. DATA QUALITY:
-- SALES CALCULATION CHECK
-- ============================================================

SELECT
    COUNT(*) AS incorrect_sales_calculations
FROM dw.fact_sales
WHERE sales_amount <> quantity * unit_price;


-- ============================================================
-- 24. DATA QUALITY:
-- SOURCE VS WAREHOUSE SALES
-- ============================================================

SELECT
    (
        SELECT SUM(oi.quantity * oi.unit_price)
        FROM public.order_items oi
    ) AS source_sales,

    (
        SELECT SUM(sales_amount)
        FROM dw.fact_sales
    ) AS warehouse_sales;


-- ============================================================
-- 25. DATA QUALITY:
-- SOURCE VS WAREHOUSE ROW COUNTS
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM public.customers) AS source_customers,
    (SELECT COUNT(*) FROM dw.dim_customer) AS warehouse_customers,

    (SELECT COUNT(*) FROM public.products) AS source_products,
    (SELECT COUNT(*) FROM dw.dim_product) AS warehouse_products,

    (SELECT COUNT(*) FROM public.order_items) AS source_order_items,
    (SELECT COUNT(*) FROM dw.fact_sales) AS warehouse_sales_rows,

    (SELECT COUNT(*) FROM public.payments) AS source_payments,
    (SELECT COUNT(*) FROM dw.fact_payments) AS warehouse_payment_rows,

    (SELECT COUNT(*) FROM public.shipments) AS source_shipments,
    (SELECT COUNT(*) FROM dw.fact_shipping) AS warehouse_shipping_rows;