CREATE SCHEMA IF NOT EXISTS dw;


-- =========================================================
-- DIMENSION: CUSTOMER
-- =========================================================

CREATE TABLE IF NOT EXISTS dw.dim_customer (
    customer_key BIGSERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    city VARCHAR(50),
    country VARCHAR(50),
    created_at TIMESTAMP NOT NULL
);


-- =========================================================
-- DIMENSION: PRODUCT
-- =========================================================

CREATE TABLE IF NOT EXISTS dw.dim_product (
    product_key BIGSERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL UNIQUE,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL
);


-- =========================================================
-- DIMENSION: DATE
-- =========================================================

CREATE TABLE IF NOT EXISTS dw.dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day INTEGER NOT NULL,
    month INTEGER NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    quarter INTEGER NOT NULL,
    year INTEGER NOT NULL,
    week INTEGER NOT NULL,
    day_of_week INTEGER NOT NULL,
    day_name VARCHAR(20) NOT NULL
);


-- =========================================================
-- DIMENSION: PAYMENT METHOD
-- =========================================================

CREATE TABLE IF NOT EXISTS dw.dim_payment_method (
    payment_method_key BIGSERIAL PRIMARY KEY,
    payment_method VARCHAR(30) NOT NULL UNIQUE
);


-- =========================================================
-- DIMENSION: SHIPPING
-- =========================================================

CREATE TABLE IF NOT EXISTS dw.dim_shipping (
    shipping_key BIGSERIAL PRIMARY KEY,
    carrier VARCHAR(50) NOT NULL,
    tracking_number VARCHAR(100) UNIQUE
);


-- =========================================================
-- FACT: SALES
-- Grain: one row per order item
-- =========================================================

CREATE TABLE IF NOT EXISTS dw.fact_sales (
    sales_key BIGSERIAL PRIMARY KEY,

    order_id INTEGER NOT NULL,
    order_item_id INTEGER NOT NULL,

    customer_key BIGINT NOT NULL,
    product_key BIGINT NOT NULL,
    date_key INTEGER NOT NULL,

    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    sales_amount DECIMAL(12,2) NOT NULL,

    CONSTRAINT fk_sales_customer
        FOREIGN KEY (customer_key)
        REFERENCES dw.dim_customer(customer_key),

    CONSTRAINT fk_sales_product
        FOREIGN KEY (product_key)
        REFERENCES dw.dim_product(product_key),

    CONSTRAINT fk_sales_date
        FOREIGN KEY (date_key)
        REFERENCES dw.dim_date(date_key),

    CONSTRAINT uq_fact_sales_order_item
        UNIQUE (order_item_id),

    CONSTRAINT chk_sales_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_sales_amount
        CHECK (sales_amount >= 0)
);


-- =========================================================
-- FACT: PAYMENTS
-- Grain: one row per payment
-- =========================================================

CREATE TABLE IF NOT EXISTS dw.fact_payments (
    payment_key BIGSERIAL PRIMARY KEY,

    payment_id INTEGER NOT NULL UNIQUE,
    order_id INTEGER NOT NULL,

    customer_key BIGINT NOT NULL,
    date_key INTEGER NOT NULL,
    payment_method_key BIGINT NOT NULL,

    amount DECIMAL(12,2) NOT NULL,

    CONSTRAINT fk_payments_customer
        FOREIGN KEY (customer_key)
        REFERENCES dw.dim_customer(customer_key),

    CONSTRAINT fk_payments_date
        FOREIGN KEY (date_key)
        REFERENCES dw.dim_date(date_key),

    CONSTRAINT fk_payments_method
        FOREIGN KEY (payment_method_key)
        REFERENCES dw.dim_payment_method(payment_method_key),

    CONSTRAINT chk_payment_amount
        CHECK (amount >= 0)
);


-- =========================================================
-- FACT: SHIPPING
-- Grain: one row per shipment
-- =========================================================

CREATE TABLE IF NOT EXISTS dw.fact_shipping (
    shipping_fact_key BIGSERIAL PRIMARY KEY,

    shipment_id INTEGER NOT NULL UNIQUE,
    order_id INTEGER NOT NULL,

    customer_key BIGINT NOT NULL,
    shipping_key BIGINT NOT NULL,

    shipped_date_key INTEGER,
    delivery_date_key INTEGER,

    delivery_days INTEGER,

    CONSTRAINT fk_shipping_customer
        FOREIGN KEY (customer_key)
        REFERENCES dw.dim_customer(customer_key),

    CONSTRAINT fk_shipping_dimension
        FOREIGN KEY (shipping_key)
        REFERENCES dw.dim_shipping(shipping_key),

    CONSTRAINT fk_shipping_shipped_date
        FOREIGN KEY (shipped_date_key)
        REFERENCES dw.dim_date(date_key),

    CONSTRAINT fk_shipping_delivery_date
        FOREIGN KEY (delivery_date_key)
        REFERENCES dw.dim_date(date_key),

    CONSTRAINT chk_delivery_days
        CHECK (delivery_days IS NULL OR delivery_days >= 0)
);