# E-Commerce Data Warehouse

An end-to-end Data Engineering portfolio project built with PostgreSQL, Python, Pandas, SQL, SQLAlchemy, and a dimensional Data Warehouse.

The project simulates an e-commerce data platform and demonstrates:

- Relational database design
- Python ETL development
- Data cleaning and validation
- Incremental data loading
- Data Warehouse modeling
- Star Schema design
- Data quality validation
- SQL analytics
- Source-to-warehouse reconciliation
- Git/GitHub version control

## 🎯 Project Goal

Build an e-commerce data platform covering:

- PostgreSQL source database
- Python ETL pipeline
- Data cleaning and validation
- Incremental ETL
- Data Warehouse
- Star Schema
- Data quality checks
- Business analytics

## 🛠️ Technologies

- Python
- Pandas
- SQL
- PostgreSQL
- SQLAlchemy
- psycopg2
- python-dotenv
- Git / GitHub

## 🗄️ Source Database

The PostgreSQL source database contains the following tables:

- `customers`
- `products`
- `orders`
- `order_items`
- `payments`
- `shipments`

## 🔄 ETL Pipeline

```text
PostgreSQL Source
       ↓
    Extract
       ↓
   CSV Raw Layer
       ↓
Pandas Transformations
       ↓
 Data Quality Checks
       ↓
CSV Processed Layer
       ↓
 Data Warehouse
       ↓
    Analytics
```

The Python ETL pipeline performs:

- PostgreSQL data extraction
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

```powershell
python src\pipeline.py
```

## 🔄 Incremental ETL

The project also implements incremental customer extraction using a timestamp watermark.

The watermark is stored in:

```text
dw.etl_control
```

The extractor reads the last successful timestamp and retrieves only customers created after that timestamp.

```text
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
```

### Incremental ETL Files

```text
src/
├── extract/
│   └── extract_customers_incremental.py
│
└── load/
    └── load_customers_incremental.py
```

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

- `dw.dim_customer`
- `dw.dim_product`
- `dw.dim_date`
- `dw.dim_payment_method`
- `dw.dim_shipping`

### Fact Tables

- `dw.fact_sales`
- `dw.fact_payments`
- `dw.fact_shipping`

### Fact Table Grain

#### `fact_sales`

One row per order item.

#### `fact_payments`

One row per payment.

#### `fact_shipping`

One row per shipment.

## ⭐ Star Schema

```text
                    dim_customer
                         |
                         |
dim_product ---- fact_sales ---- dim_date
                         |
                         |
                   dim_shipping


              dim_payment_method
                       |
                       |
                 fact_payments


                  dim_customer
                       |
                       |
                 fact_shipping
                       |
                       |
                  dim_shipping
```

## 📊 Current Dataset

| Source Table | Rows |
|---|---:|
| Customers | 8 |
| Products | 6 |
| Orders | 8 |
| Order Items | 15 |
| Payments | 8 |
| Shipments | 5 |

The source data was reconciled against the Data Warehouse and the corresponding row counts matched.

## 🔎 Analytics

The warehouse supports analysis of:

- Total sales
- Sales by product
- Sales by product category
- Sales by customer
- Sales by city
- Sales by country
- Monthly sales
- Quarterly sales
- Daily sales
- Units sold
- Average order value
- Product revenue rankings
- Customer revenue rankings
- Payment methods
- Payment amounts
- Shipping performance
- Delivery time
- Data quality
- Source-to-warehouse reconciliation

### Example Business Questions

- What is the total sales amount?
- What are the monthly sales?
- Which products generate the most revenue?
- Which product categories generate the most revenue?
- How much did each customer spend?
- Which customers generated the most sales?
- Which payment methods are used?
- How many shipments have been delivered?
- What is the average delivery time by carrier?
- Does warehouse revenue match the source data?

## ✅ Data Quality Validation

The warehouse includes validation checks for:

- Orphan customer keys
- Orphan product keys
- Orphan date keys
- Invalid quantities
- Negative prices
- Negative sales amounts
- Incorrect sales calculations
- Source vs warehouse revenue
- Source vs warehouse row counts

### Revenue Reconciliation

```text
Source sales:     43,950.00
Warehouse sales:  43,950.00
```

### Row Count Reconciliation

```text
Customers:     8 = 8
Products:      6 = 6
Order Items:  15 = 15
Payments:      8 = 8
Shipments:     5 = 5
```

The warehouse integrity checks returned zero invalid or orphan records.

## ⚙️ Environment Configuration

Database connection settings are stored in environment variables rather than hard-coded in the source code.

Example:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ecommerce_db
DB_USER=postgres
DB_PASSWORD=your_password
```

The `.env` file is excluded from Git using `.gitignore`.

## 📁 Project Structure

```text
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
```

## 🗂️ SQL Organization

```text
sql/
├── staging/
│   ├── 01_create_database.sql
│   └── 02_create_tables.sql
│
├── warehouse/
│   ├── 01_create_star_schema.sql
│   └── 02_load_star_schema.sql
│
└── analytics/
    ├── 01_basic_analysis.sql
    └── 01_warehouse_analysis.sql
```

The warehouse SQL contains the Star Schema creation and loading logic, while the analytics SQL contains business analysis and data-quality queries.

## 🧪 ETL Testing

The incremental ETL was tested using newly created customer records.

The pipeline successfully:

- Detected new customer records
- Extracted only records after the stored watermark
- Loaded the new records into `dw.dim_customer`
- Updated the watermark
- Returned zero new records on a subsequent run when no new data existed

This demonstrates the incremental loading behavior of the pipeline.

## 🗺️ Project Status

- [x] PostgreSQL Source Database
- [x] SQL Analysis
- [x] Python ETL
- [x] Pandas Transformations
- [x] Data Quality Checks
- [x] Data Warehouse
- [x] Star Schema
- [x] Incremental Customer ETL
- [x] Environment-based Database Configuration
- [x] Warehouse Analytics
- [x] Source-to-Warehouse Reconciliation
- [x] GitHub Version Control
- [x] Final Project Validation

## 🚀 Project Scope

This project focuses on the core Data Engineering concepts:

```text
Source Database
      ↓
Python ETL
      ↓
Incremental ETL
      ↓
Data Warehouse
      ↓
Star Schema
      ↓
Data Quality
      ↓
Analytics
```

Additional technologies such as Docker, Apache Spark, and Apache Airflow are intentionally outside the scope of this project and can be explored in separate Data Engineering projects.

## 👨‍💻 Author

**KHALID CHABAB**

Data Engineering Portfolio Project