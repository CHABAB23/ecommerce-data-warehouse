# E-Commerce Data Warehouse

A hands-on Data Engineering project built with Python, SQL, PostgreSQL, and an evolving ETL/Data Warehouse architecture.

---

## 🎯 Project Goal

Build an end-to-end e-commerce data platform that demonstrates:

- Relational database design
- PostgreSQL
- SQL analysis
- Data extraction
- Data transformation
- Data quality validation
- Python ETL pipelines
- Data Warehouse modeling
- Docker
- Apache Spark
- Apache Airflow

The project is developed progressively, starting with a transactional PostgreSQL source database and evolving toward a complete analytical Data Warehouse.

---

# 🏗️ Current Architecture

```text
                    PostgreSQL
                 Source Database
                       │
                       ▼
                 Python Extract
                       │
                       ▼
                  CSV Raw Layer
                       │
                       ▼
              Python Transformations
                       │
          ┌────────────┼────────────┐
          ▼            ▼            ▼
     Customers     Products       Orders
          │            │            │
          └────────────┼────────────┘
                       │
                       ▼
                Processed CSV
                       │
                       ▼
               Data Warehouse
                  (Planned)
```

---

# 🛠️ Technologies

## Current

- Python
- Pandas
- SQL
- PostgreSQL
- pgAdmin
- CSV
- Git
- GitHub

## Planned

- SQLAlchemy
- Docker
- Apache Spark
- PySpark
- Data Warehouse
- Apache Airflow
- Data Quality Testing
- Pipeline Monitoring

---

# 🗄️ Source Database

The PostgreSQL source database contains six main tables.

## Customers

Stores customer information.

```text
customer_id
first_name
last_name
email
phone
city
country
created_at
```

## Products

Stores product information and inventory.

```text
product_id
product_name
category
price
stock_quantity
created_at
```

## Orders

Stores customer orders.

```text
order_id
customer_id
order_date
status
```

## Order Items

Stores the products included in each order.

```text
order_item_id
order_id
product_id
quantity
unit_price
```

## Payments

Stores payment transactions.

```text
payment_id
order_id
payment_method
amount
payment_date
```

## Shipments

Stores shipping and delivery information.

```text
shipment_id
order_id
carrier
tracking_number
shipped_date
delivery_date
```

---

# 📊 Current Dataset

The development dataset currently contains:

| Table | Records |
|---|---:|
| Customers | 5 |
| Products | 6 |
| Orders | 8 |
| Order Items | 15 |
| Payments | 8 |
| Shipments | 5 |

The dataset is intentionally small during development so that the database structure, SQL logic, ETL transformations, and data-quality checks can be tested and understood before working with larger datasets.

---

# 🔎 SQL Analysis

The PostgreSQL source database includes SQL analysis for:

- Customer and order analysis
- Customer order history
- Order status analysis
- Product sales analysis
- Units sold
- Best-selling products
- Total revenue
- Revenue by order
- Revenue by payment method
- Shipment analysis
- Data-quality checks

---

# 🐍 Python ETL Pipeline

Phase 2 introduces a Python-based ETL pipeline.

The pipeline extracts data from PostgreSQL, stores the source data in a raw CSV layer, transforms the datasets with Pandas, performs data-quality checks, and saves the cleaned datasets into a processed layer.

## ETL Flow

```text
PostgreSQL
    │
    ▼
Extract
    │
    ▼
data/raw/
    │
    ▼
Transform with Pandas
    │
    ▼
Data Quality Checks
    │
    ▼
data/processed/
```

---

## 1. Extraction

The extraction script connects to the PostgreSQL source database and extracts all six source tables.

```text
src/extract/extract_data.py
```

The current extraction process produces:

```text
customers: 5 rows extracted
products: 6 rows extracted
orders: 8 rows extracted
order_items: 15 rows extracted
payments: 8 rows extracted
shipments: 5 rows extracted
```

---

## 2. Raw Data Layer

Extracted PostgreSQL data is stored as CSV files in:

```text
data/raw/
```

Current raw datasets:

```text
customers.csv
products.csv
orders.csv
order_items.csv
payments.csv
shipments.csv
```

The raw layer represents the extracted source data before transformation.

---

# 🔄 Data Transformation

Transformations are implemented with Python and Pandas.

```text
src/transform/
```

Current transformation scripts:

```text
transform_customers.py
transform_products.py
transform_orders.py
transform_order_items.py
transform_payments.py
transform_shipments.py
```

---

## Customers Transformation

The customer transformation includes:

- Duplicate customer handling
- Name cleaning
- Email normalization
- Phone cleaning
- Moroccan phone-number normalization
- City normalization
- Country normalization
- Date conversion
- Data-quality checks

Example:

```text
Raw phone:
612345678

Transformed phone:
0612345678
```

---

## Products Transformation

The product transformation includes:

- Duplicate product handling
- Product name cleaning
- Category normalization
- Numeric price conversion
- Stock quantity validation
- Negative price detection
- Negative stock detection
- Date conversion
- Data-quality checks

---

## Orders Transformation

The order transformation includes:

- Duplicate order handling
- Order ID validation
- Customer ID validation
- Order date conversion
- Order status validation
- Referential checks
- Data-quality checks

---

## Order Items Transformation

The order-item transformation includes:

- Duplicate order-item handling
- Order ID validation
- Product ID validation
- Quantity validation
- Unit-price validation
- Negative price detection
- Referential checks

---

## Payments Transformation

The payment transformation includes:

- Duplicate payment handling
- Payment ID validation
- Order ID validation
- Payment method normalization
- Payment method validation
- Amount validation
- Negative amount detection
- Payment date conversion

---

## Shipments Transformation

The shipment transformation includes:

- Duplicate shipment handling
- Shipment ID validation
- Order ID validation
- Tracking-number validation
- Carrier validation
- Shipped-date conversion
- Delivery-date conversion
- Missing delivery-date detection
- Delivery-before-shipped validation

Two shipment records currently have missing delivery dates because those shipments have not been delivered yet.

---

# 🧪 Data Quality Checks

The ETL pipeline performs basic data-quality checks before saving processed datasets.

Examples include:

```text
Duplicate IDs
Missing IDs
Missing required fields
Invalid dates
Invalid numeric values
Negative prices
Negative quantities
Invalid payment methods
Invalid order IDs
Invalid product IDs
Invalid customer IDs
Delivery dates before shipped dates
```

Current pipeline execution completes successfully.

Example:

```text
Customers
Duplicate customer IDs: 0
Missing customer IDs: 0
Missing emails: 0
Invalid dates: 0

Products
Duplicate product IDs: 0
Missing product IDs: 0
Invalid prices: 0
Negative prices: 0
Negative stock quantities: 0
Invalid dates: 0

Orders
Duplicate order IDs: 0
Missing order IDs: 0
Missing customer IDs: 0
Invalid order dates: 0
Invalid order statuses: 0
Invalid customer IDs: 0

Order Items
Duplicate order item IDs: 0
Missing order item IDs: 0
Missing order IDs: 0
Missing product IDs: 0
Invalid quantities: 0
Negative unit prices: 0

Payments
Duplicate payment IDs: 0
Missing payment IDs: 0
Missing order IDs: 0
Missing payment methods: 0
Invalid payment methods: 0
Invalid amounts: 0
Negative amounts: 0
Invalid payment dates: 0
Invalid order IDs: 0

Shipments
Duplicate shipment IDs: 0
Missing shipment IDs: 0
Missing order IDs: 0
Missing tracking numbers: 0
Invalid carriers: 0
Invalid shipped dates: 0
Delivery dates before shipped dates: 0
Invalid order IDs: 0
```

---

# 🚀 ETL Pipeline Execution

All extraction and transformation steps can be executed through one pipeline:

```powershell
python src\pipeline.py
```

The pipeline executes:

```text
1. Extract PostgreSQL data
          ↓
2. Create raw CSV datasets
          ↓
3. Transform customers
          ↓
4. Transform products
          ↓
5. Transform orders
          ↓
6. Transform order items
          ↓
7. Transform payments
          ↓
8. Transform shipments
          ↓
9. Save processed datasets
```

Successful execution ends with:

```text
ETL PIPELINE COMPLETED SUCCESSFULLY
```

---

# 📁 Project Structure

Current project structure:

```text
ecommerce-data-warehouse/
│
├── data/
│   ├── raw/
│   │   ├── customers.csv
│   │   ├── products.csv
│   │   ├── orders.csv
│   │   ├── order_items.csv
│   │   ├── payments.csv
│   │   └── shipments.csv
│   │
│   └── processed/
│       ├── customers.csv
│       ├── products.csv
│       ├── orders.csv
│       ├── order_items.csv
│       ├── payments.csv
│       └── shipments.csv
│
├── sql/
│   ├── staging/
│   │   ├── 01_create_database.sql
│   │   └── 02_create_tables.sql
│   │
│   └── analytics/
│       └── 01_basic_analysis.sql
│
├── src/
│   ├── extract/
│   │   └── extract_data.py
│   │
│   ├── transform/
│   │   ├── transform_customers.py
│   │   ├── transform_products.py
│   │   ├── transform_orders.py
│   │   ├── transform_order_items.py
│   │   ├── transform_payments.py
│   │   └── transform_shipments.py
│   │
│   └── pipeline.py
│
├── .gitignore
├── README.md
└── requirements.txt
```

---

# 📦 Raw vs Processed Data

The project separates source data from transformed data.

## Raw

```text
data/raw/
```

Contains data extracted from PostgreSQL with minimal modification.

## Processed

```text
data/processed/
```

Contains cleaned and validated datasets ready for the next stage of the Data Engineering pipeline.

This separation makes the ETL process easier to reproduce, debug, and maintain.

---

# 🏭 Data Warehouse — Planned

The next major phase is to build an analytical Data Warehouse using a Star Schema.

## Planned Dimensions

```text
dim_customer
dim_product
dim_date
dim_payment_method
dim_shipping
```

## Planned Fact Tables

```text
fact_sales
fact_payments
```

The Data Warehouse will separate analytical workloads from the transactional PostgreSQL source system.

---

# 🚧 Project Roadmap

## Phase 1 — PostgreSQL Source Database

- [x] Create PostgreSQL database
- [x] Design relational schema
- [x] Create tables
- [x] Add primary keys
- [x] Add foreign keys
- [x] Add constraints
- [x] Insert sample data
- [x] Write SQL joins
- [x] Calculate revenue
- [x] Analyze products
- [x] Analyze payments
- [x] Create data-quality checks

---

## Phase 2 — Python ETL Pipeline

- [x] Extract data from PostgreSQL
- [x] Create CSV raw layer
- [x] Read datasets with Pandas
- [x] Clean customer data
- [x] Clean product data
- [x] Clean order data
- [x] Clean order-item data
- [x] Clean payment data
- [x] Clean shipment data
- [x] Remove duplicates
- [x] Normalize strings
- [x] Normalize emails
- [x] Clean phone numbers
- [x] Convert dates
- [x] Validate numeric fields
- [x] Validate relationships
- [x] Implement data-quality checks
- [x] Create processed CSV layer
- [x] Create complete ETL pipeline

---

## Phase 3 — Data Warehouse

- [ ] Design Star Schema
- [ ] Create dimension tables
- [ ] Create fact tables
- [ ] Create date dimension
- [ ] Add surrogate keys
- [ ] Load dimensions
- [ ] Load facts
- [ ] Implement analytical queries

---

## Phase 4 — Advanced Data Engineering

- [ ] Incremental data loading
- [ ] Full vs incremental ETL
- [ ] ETL idempotency
- [ ] Advanced data validation
- [ ] Duplicate detection
- [ ] Slowly Changing Dimensions
- [ ] Surrogate keys
- [ ] Pipeline monitoring

---

## Phase 5 — Docker

Containerize the project.

Planned services:

```text
┌──────────────────────┐
│ PostgreSQL           │
└──────────────────────┘

┌──────────────────────┐
│ Python ETL           │
└──────────────────────┘

┌──────────────────────┐
│ Data Warehouse       │
└──────────────────────┘
```

---

## Phase 6 — Apache Spark

Introduce Spark/PySpark for large-scale data processing.

Planned tasks:

- [ ] Spark DataFrames
- [ ] Transformations
- [ ] Aggregations
- [ ] Joins
- [ ] Partitioning
- [ ] PySpark ETL
- [ ] Large dataset processing

---

## Phase 7 — Orchestration

Build an automated data pipeline.

```text
Source Data
     │
     ▼
Extract
     │
     ▼
Transform
     │
     ▼
Validate
     │
     ▼
Load
     │
     ▼
Data Warehouse
     │
     ▼
Analytics
```

Planned orchestration:

- [ ] Apache Airflow
- [ ] Scheduled pipelines
- [ ] Pipeline dependencies
- [ ] Retry handling
- [ ] Logging
- [ ] Monitoring

---

# 📈 Example Business Questions

The final platform will be designed to answer questions such as:

- What is the total revenue?
- Which products generate the most revenue?
- Which products sell the most units?
- What is revenue by month?
- What is revenue by customer?
- Which categories perform best?
- What payment methods are used?
- How long does delivery take?
- Which customers have the highest lifetime value?
- How does revenue change over time?

---

# 🎓 Skills Demonstrated

```text
Python
├── Pandas
├── Data Processing
├── ETL
└── Automation

SQL
├── Joins
├── Aggregations
├── CTEs
├── Window Functions
└── Data Quality

PostgreSQL
├── Database Design
├── Constraints
├── Relationships
└── Transactions

ETL
├── Extraction
├── Raw Data Layer
├── Transformation
├── Validation
└── Processed Data Layer

Data Warehouse
├── Star Schema
├── Fact Tables
├── Dimension Tables
└── Slowly Changing Dimensions

Big Data
└── Apache Spark

DevOps
├── Git
└── Docker

Orchestration
└── Apache Airflow
```

---

# 🚀 Project Status

**Current stage: Phase 2 — Python ETL Pipeline**

Phase 1 is complete:

- PostgreSQL source database created
- Relational schema implemented
- Sample data inserted
- SQL analysis completed
- Data-quality queries created

Phase 2 is complete:

- PostgreSQL extraction implemented
- Raw CSV layer implemented
- Pandas transformations implemented
- Duplicate handling implemented
- String cleaning implemented
- Email normalization implemented
- Phone normalization implemented
- Date conversion implemented
- Data-quality validation implemented
- Processed CSV layer implemented
- Complete ETL pipeline implemented

The next milestone is **Phase 3 — Data Warehouse**, where the processed datasets will be modeled into dimensions and fact tables using a Star Schema.

---

## 👨‍💻 Author

KHALID CHABAB

Data Engineering Portfolio Project