-- ============================================================
-- E-COMMERCE DATA WAREHOUSE
-- Source Database Tables
-- ============================================================


-- ============================================================
-- 1. CUSTOMERS
-- ============================================================

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    city VARCHAR(50),
    country VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 2. PRODUCTS
-- ============================================================

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL
        CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0
        CHECK (stock_quantity >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 3. ORDERS
-- ============================================================

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,

    status VARCHAR(20) NOT NULL
        CHECK (
            status IN (
                'Pending',
                'Shipped',
                'Delivered',
                'Cancelled'
            )
        ),

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);


-- ============================================================
-- 4. ORDER ITEMS
-- ============================================================

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,

    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,

    quantity INTEGER NOT NULL
        CHECK (quantity > 0),

    unit_price DECIMAL(10,2) NOT NULL
        CHECK (unit_price >= 0),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);


-- ============================================================
-- 5. PAYMENTS
-- ============================================================

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,

    order_id INTEGER NOT NULL,

    payment_method VARCHAR(30) NOT NULL,

    amount DECIMAL(10,2) NOT NULL
        CHECK (amount >= 0),

    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    UNIQUE (order_id)
);


-- ============================================================
-- 6. SHIPMENTS
-- ============================================================

CREATE TABLE shipments (
    shipment_id SERIAL PRIMARY KEY,

    order_id INTEGER NOT NULL,

    carrier VARCHAR(50) NOT NULL,

    tracking_number VARCHAR(100) UNIQUE,

    shipped_date DATE,

    delivery_date DATE,

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    UNIQUE (order_id)
);