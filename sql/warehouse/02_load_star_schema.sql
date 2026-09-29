-- =========================================================
-- LOAD DIM_CUSTOMER
-- SCD TYPE 1
-- =========================================================

INSERT INTO dw.dim_customer (
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    city,
    country,
    created_at
)
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    city,
    country,
    created_at
FROM public.customers
ON CONFLICT (customer_id)
DO UPDATE SET
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    email = EXCLUDED.email,
    phone = EXCLUDED.phone,
    city = EXCLUDED.city,
    country = EXCLUDED.country;


-- =========================================================
-- LOAD DIM_PRODUCT
-- =========================================================

INSERT INTO dw.dim_product (
    product_id,
    product_name,
    category,
    price,
    stock_quantity,
    created_at
)
SELECT
    product_id,
    product_name,
    category,
    price,
    stock_quantity,
    created_at
FROM public.products
ON CONFLICT (product_id)
DO UPDATE SET
    product_name = EXCLUDED.product_name,
    category = EXCLUDED.category,
    price = EXCLUDED.price,
    stock_quantity = EXCLUDED.stock_quantity;


-- =========================================================
-- LOAD DIM_DATE
-- Covers order, payment and shipment dates
-- =========================================================

WITH date_bounds AS (
    SELECT
        LEAST(
            COALESCE((SELECT MIN(order_date) FROM public.orders), CURRENT_DATE),
            COALESCE((SELECT MIN(payment_date) FROM public.payments), CURRENT_DATE),
            COALESCE((SELECT MIN(shipped_date) FROM public.shipments), CURRENT_DATE),
            COALESCE((SELECT MIN(delivery_date) FROM public.shipments), CURRENT_DATE)
        ) AS min_date,

        GREATEST(
            COALESCE((SELECT MAX(order_date) FROM public.orders), CURRENT_DATE),
            COALESCE((SELECT MAX(payment_date) FROM public.payments), CURRENT_DATE),
            COALESCE((SELECT MAX(shipped_date) FROM public.shipments), CURRENT_DATE),
            COALESCE((SELECT MAX(delivery_date) FROM public.shipments), CURRENT_DATE)
        ) AS max_date
)
INSERT INTO dw.dim_date (
    date_key,
    full_date,
    day,
    month,
    month_name,
    quarter,
    year,
    week,
    day_of_week,
    day_name
)
SELECT
    TO_CHAR(d.full_date, 'YYYYMMDD')::INTEGER,
    d.full_date,
    EXTRACT(DAY FROM d.full_date)::INTEGER,
    EXTRACT(MONTH FROM d.full_date)::INTEGER,
    TO_CHAR(d.full_date, 'FMMonth'),
    EXTRACT(QUARTER FROM d.full_date)::INTEGER,
    EXTRACT(YEAR FROM d.full_date)::INTEGER,
    EXTRACT(WEEK FROM d.full_date)::INTEGER,
    EXTRACT(ISODOW FROM d.full_date)::INTEGER,
    TO_CHAR(d.full_date, 'FMDay')
FROM date_bounds b
CROSS JOIN LATERAL (
    SELECT generate_series(
        b.min_date,
        b.max_date,
        INTERVAL '1 day'
    )::DATE AS full_date
) d
ON CONFLICT (date_key)
DO NOTHING;


-- =========================================================
-- LOAD DIM_PAYMENT_METHOD
-- =========================================================

INSERT INTO dw.dim_payment_method (
    payment_method
)
SELECT DISTINCT
    payment_method
FROM public.payments
ON CONFLICT (payment_method)
DO NOTHING;


-- =========================================================
-- LOAD DIM_SHIPPING
-- One row per carrier/tracking combination
-- =========================================================

INSERT INTO dw.dim_shipping (
    carrier,
    tracking_number
)
SELECT
    carrier,
    tracking_number
FROM public.shipments
ON CONFLICT (tracking_number)
DO NOTHING;


-- =========================================================
-- LOAD FACT_SALES
-- Grain: one row per order item
-- =========================================================

INSERT INTO dw.fact_sales (
    order_id,
    order_item_id,
    customer_key,
    product_key,
    date_key,
    quantity,
    unit_price,
    sales_amount
)
SELECT
    o.order_id,
    oi.order_item_id,
    dc.customer_key,
    dp.product_key,
    dd.date_key,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price
FROM public.orders o
JOIN public.order_items oi
    ON oi.order_id = o.order_id
JOIN dw.dim_customer dc
    ON dc.customer_id = o.customer_id
JOIN dw.dim_product dp
    ON dp.product_id = oi.product_id
JOIN dw.dim_date dd
    ON dd.full_date = o.order_date
ON CONFLICT (order_item_id)
DO UPDATE SET
    customer_key = EXCLUDED.customer_key,
    product_key = EXCLUDED.product_key,
    date_key = EXCLUDED.date_key,
    quantity = EXCLUDED.quantity,
    unit_price = EXCLUDED.unit_price,
    sales_amount = EXCLUDED.sales_amount;


-- =========================================================
-- LOAD FACT_PAYMENTS
-- Grain: one row per payment
-- =========================================================

INSERT INTO dw.fact_payments (
    payment_id,
    order_id,
    customer_key,
    date_key,
    payment_method_key,
    amount
)
SELECT
    p.payment_id,
    p.order_id,
    dc.customer_key,
    dd.date_key,
    dpm.payment_method_key,
    p.amount
FROM public.payments p
JOIN public.orders o
    ON o.order_id = p.order_id
JOIN dw.dim_customer dc
    ON dc.customer_id = o.customer_id
JOIN dw.dim_date dd
    ON dd.full_date = p.payment_date
JOIN dw.dim_payment_method dpm
    ON dpm.payment_method = p.payment_method
ON CONFLICT (payment_id)
DO UPDATE SET
    order_id = EXCLUDED.order_id,
    customer_key = EXCLUDED.customer_key,
    date_key = EXCLUDED.date_key,
    payment_method_key = EXCLUDED.payment_method_key,
    amount = EXCLUDED.amount;


-- =========================================================
-- LOAD FACT_SHIPPING
-- Grain: one row per shipment
-- =========================================================

INSERT INTO dw.fact_shipping (
    shipment_id,
    order_id,
    customer_key,
    shipping_key,
    shipped_date_key,
    delivery_date_key,
    delivery_days
)
SELECT
    s.shipment_id,
    s.order_id,
    dc.customer_key,
    ds.shipping_key,
    shipped_date.date_key,
    delivery_date.date_key,

    CASE
        WHEN s.shipped_date IS NOT NULL
         AND s.delivery_date IS NOT NULL
        THEN s.delivery_date - s.shipped_date
        ELSE NULL
    END

FROM public.shipments s

JOIN public.orders o
    ON o.order_id = s.order_id

JOIN dw.dim_customer dc
    ON dc.customer_id = o.customer_id

JOIN dw.dim_shipping ds
    ON ds.tracking_number = s.tracking_number

LEFT JOIN dw.dim_date shipped_date
    ON shipped_date.full_date = s.shipped_date

LEFT JOIN dw.dim_date delivery_date
    ON delivery_date.full_date = s.delivery_date

ON CONFLICT (shipment_id)
DO UPDATE SET
    order_id = EXCLUDED.order_id,
    customer_key = EXCLUDED.customer_key,
    shipping_key = EXCLUDED.shipping_key,
    shipped_date_key = EXCLUDED.shipped_date_key,
    delivery_date_key = EXCLUDED.delivery_date_key,
    delivery_days = EXCLUDED.delivery_days;