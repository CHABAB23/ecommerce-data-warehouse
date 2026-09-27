-- ============================================================
-- E-COMMERCE DATA WAREHOUSE
-- Warehouse Analysis
-- ============================================================


-- ============================================================
-- 1. Warehouse Row Counts
-- ============================================================

SELECT 'dim_customer' AS table_name, COUNT(*) AS row_count
FROM dw.dim_customer

UNION ALL

SELECT 'dim_product', COUNT(*)
FROM dw.dim_product

UNION ALL

SELECT 'dim_date', COUNT(*)
FROM dw.dim_date

UNION ALL

SELECT 'dim_payment_method', COUNT(*)
FROM dw.dim_payment_method

UNION ALL

SELECT 'dim_shipping', COUNT(*)
FROM dw.dim_shipping

UNION ALL

SELECT 'fact_sales', COUNT(*)
FROM dw.fact_sales

UNION ALL

SELECT 'fact_payments', COUNT(*)
FROM dw.fact_payments;


-- ============================================================
-- 2. Total Sales Revenue
-- ============================================================

SELECT
    SUM(sales_amount) AS total_revenue
FROM dw.fact_sales;


-- ============================================================
-- 3. Revenue by Product
-- ============================================================

SELECT
    dp.product_id,
    dp.product_name,
    dp.category,
    SUM(fs.quantity) AS units_sold,
    SUM(fs.sales_amount) AS revenue
FROM dw.fact_sales fs
JOIN dw.dim_product dp
    ON fs.product_key = dp.product_key
GROUP BY
    dp.product_id,
    dp.product_name,
    dp.category
ORDER BY revenue DESC;


-- ============================================================
-- 4. Revenue by Category
-- ============================================================

SELECT
    dp.category,
    SUM(fs.quantity) AS units_sold,
    SUM(fs.sales_amount) AS revenue
FROM dw.fact_sales fs
JOIN dw.dim_product dp
    ON fs.product_key = dp.product_key
GROUP BY dp.category
ORDER BY revenue DESC;


-- ============================================================
-- 5. Revenue by Customer
-- ============================================================

SELECT
    dc.customer_id,
    dc.first_name,
    dc.last_name,
    dc.city,
    SUM(fs.sales_amount) AS total_revenue
FROM dw.fact_sales fs
JOIN dw.dim_customer dc
    ON fs.customer_key = dc.customer_key
GROUP BY
    dc.customer_id,
    dc.first_name,
    dc.last_name,
    dc.city
ORDER BY total_revenue DESC;


-- ============================================================
-- 6. Revenue by Month
-- ============================================================

SELECT
    d.year,
    d.month,
    d.month_name,
    SUM(fs.sales_amount) AS monthly_revenue
FROM dw.fact_sales fs
JOIN dw.dim_date d
    ON fs.order_date_key = d.date_key
GROUP BY
    d.year,
    d.month,
    d.month_name
ORDER BY
    d.year,
    d.month;


-- ============================================================
-- 7. Units Sold by Product
-- ============================================================

SELECT
    dp.product_name,
    SUM(fs.quantity) AS units_sold
FROM dw.fact_sales fs
JOIN dw.dim_product dp
    ON fs.product_key = dp.product_key
GROUP BY dp.product_name
ORDER BY units_sold DESC;


-- ============================================================
-- 8. Revenue by Payment Method
-- ============================================================

SELECT
    dpm.payment_method,
    SUM(fp.amount) AS total_payment
FROM dw.fact_payments fp
JOIN dw.dim_payment_method dpm
    ON fp.payment_method_key = dpm.payment_method_key
GROUP BY dpm.payment_method
ORDER BY total_payment DESC;


-- ============================================================
-- 9. Revenue by Shipping Carrier
-- ============================================================

SELECT
    ds.carrier,
    SUM(fs.sales_amount) AS revenue
FROM dw.fact_sales fs
JOIN dw.dim_shipping ds
    ON fs.shipping_key = ds.shipping_key
GROUP BY ds.carrier
ORDER BY revenue DESC;


-- ============================================================
-- 10. Order-Level Revenue
-- ============================================================

SELECT
    fs.order_id,
    SUM(fs.sales_amount) AS order_revenue
FROM dw.fact_sales fs
GROUP BY fs.order_id
ORDER BY fs.order_id;


-- ============================================================
-- 11. Average Order Value
-- ============================================================

SELECT
    ROUND(
        SUM(sales_amount) / COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM dw.fact_sales;


-- ============================================================
-- 12. Customer Order Count
-- ============================================================

SELECT
    dc.customer_id,
    dc.first_name,
    dc.last_name,
    COUNT(DISTINCT fs.order_id) AS order_count
FROM dw.fact_sales fs
JOIN dw.dim_customer dc
    ON fs.customer_key = dc.customer_key
GROUP BY
    dc.customer_id,
    dc.first_name,
    dc.last_name
ORDER BY order_count DESC;


-- ============================================================
-- 13. Data Quality - Fact Sales
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE quantity <= 0) AS invalid_quantities,
    COUNT(*) FILTER (WHERE unit_price < 0) AS negative_prices,
    COUNT(*) FILTER (WHERE sales_amount < 0) AS negative_sales
FROM dw.fact_sales;


-- ============================================================
-- 14. Payment Reconciliation
-- ============================================================

SELECT
    (SELECT SUM(sales_amount)
     FROM dw.fact_sales) AS sales_total,

    (SELECT SUM(amount)
     FROM dw.fact_payments) AS payment_total,

    (SELECT SUM(sales_amount)
     FROM dw.fact_sales)
    -
    (SELECT SUM(amount)
     FROM dw.fact_payments) AS difference;