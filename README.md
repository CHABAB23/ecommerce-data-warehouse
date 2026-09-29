# E-Commerce Data Warehouse

An end-to-end Data Engineering project using PostgreSQL, Python, Pandas, SQL, and a Data Warehouse.

The project simulates an e-commerce data platform and demonstrates:

- Relational database design
- ETL development
- Data cleaning and validation
- Incremental data loading
- Data Warehouse modeling
- SQL analytics

## 🎯 Project Goal

Build an e-commerce data platform covering:

- PostgreSQL source database
- Python ETL pipeline
- Data cleaning and validation
- Incremental ETL
- Data Warehouse
- SQL analytics

## 🛠️ Technologies

- Python
- Pandas
- SQL
- PostgreSQL
- psycopg2
- Git / GitHub

Planned:

- Docker
- Apache Spark / PySpark
- Apache Airflow

## 🗄️ Source Database

The PostgreSQL database contains:

    customers
    products
    orders
    order_items
    payments
    shipments

## 🔄 ETL Pipeline

    PostgreSQL
        ↓
    Extract
        ↓
    CSV Raw Layer
        ↓
    Pandas Transform
        ↓
    Data Quality Checks
        ↓
    CSV Processed Layer
        ↓
    Data Warehouse
        ↓
    Analytics

The Python ETL pipeline performs:

- PostgreSQL extraction
- CSV generation
- Duplicate handling
- String cleaning
- Email normalization
- Phone normalization
- Numeric validation
- Date conversion
- Foreign-key validation
- Data-quality checks

Run the complete pipeline:

    python src\pipeline.py

## 🔄 Incremental ETL

The project also implements incremental customer extraction.

The pipeline uses a timestamp watermark stored in:

    dw.etl_control

The extractor reads the last successful timestamp and retrieves only customers created after that timestamp.

    PostgreSQL
        ↓
    Read last successful watermark
        ↓
    Extract new customers
        ↓
    customers_incremental.csv
        ↓
    Load into dw.dim_customer
        ↓
    Update ETL watermark
        ↓
    Commit transaction

Main files:

    src/
    ├── extract/
    │   └── extract_customers_incremental.py
    │
    └── load/
        └── load_customers_incremental.py

The incremental loader:

- Reads incremental CSV data
- Checks for existing customers
- Inserts new customers
- Tracks inserted and skipped records
- Updates the ETL watermark
- Uses a database transaction
- Rolls back the transaction if an error occurs

## 🏢 Data Warehouse

The Data Warehouse uses a Star Schema.

### Dimensions

    dim_customer
    dim_product
    dim_date
    dim_payment_method
    dim_shipping

### Facts

    fact_sales
    fact_payments

## 📊 Current Dataset

| Table       | Rows |
|-------------|-----:|
| Customers   | 5 |
| Products    | 6 |
| Orders      | 8 |
| Order Items | 15 |
| Payments    | 8 |
| Shipments   | 5 |

## 🔎 Analytics

The project supports analysis of:

- Total revenue
- Revenue by product
- Revenue by customer
- Revenue by month
- Units sold
- Order status
- Payment methods
- Shipment and delivery performance

Example business questions:

- What is monthly revenue?
- Which product generates the most revenue?
- How much did each customer spend?

## 📁 Project Structure

    ecommerce-data-warehouse/
    │
    ├── data/
    │   ├── raw/
    │   └── processed/
    │
    ├── sql/
    │   ├── staging/
    │   ├── analytics/
    │   └── warehouse/
    │
    ├── src/
    │   ├── extract/
    │   │   ├── extract_data.py
    │   │   └── extract_customers_incremental.py
    │   │
    │   ├── transform/
    │   │   ├── transform_customers.py
    │   │   ├── transform_data.py
    │   │   ├── transform_order_items.py
    │   │   ├── transform_orders.py
    │   │   ├── transform_payments.py
    │   │   ├── transform_products.py
    │   │   └── transform_shipments.py
    │   │
    │   ├── load/
    │   │   └── load_customers_incremental.py
    │   │
    │   └── pipeline.py
    │
    ├── .gitignore
    ├── requirements.txt
    └── README.md

## 🚧 Roadmap

- [x] PostgreSQL Source Database
- [x] SQL Analysis
- [x] Python ETL
- [x] Pandas Transformations
- [x] Data Quality Checks
- [x] Data Warehouse
- [x] Incremental Customer ETL
- [ ] Environment-based database configuration
- [ ] Docker
- [ ] Apache Spark
- [ ] Apache Airflow

## 👨‍💻 Author

KHALID CHABAB

Data Engineering Portfolio Project