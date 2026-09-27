# E-Commerce Data Warehouse

An end-to-end Data Engineering project using PostgreSQL, Python, Pandas, SQL, and a Data Warehouse.

## 🎯 Project Goal

Build an e-commerce data platform covering:

- PostgreSQL source database
- Python ETL pipeline
- Data cleaning and validation
- Data Warehouse
- SQL analytics

## 🛠️ Technologies

- Python
- Pandas
- SQL
- PostgreSQL
- Git / GitHub

Planned:

- Docker
- Apache Spark / PySpark
- Apache Airflow

## 🗄️ Source Database

The PostgreSQL database contains:

```text
customers
products
orders
order_items
payments
shipments
```

## 🔄 ETL Pipeline

```text
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
```

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

```powershell
python src\pipeline.py
```

## 🏢 Data Warehouse

The Data Warehouse uses a Star Schema.

### Dimensions

```text
dim_customer
dim_product
dim_date
dim_payment_method
dim_shipping
```

### Facts

```text
fact_sales
fact_payments
```

## 📊 Current Dataset

| Table | Rows |
|---|---:|
| Customers | 5 |
| Products | 6 |
| Orders | 8 |
| Order Items | 15 |
| Payments | 8 |
| Shipments | 5 |

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
│   ├── transform/
│   └── pipeline.py
│
├── .gitignore
├── requirements.txt
└── README.md
```

## 🚧 Roadmap

- [x] PostgreSQL Source Database
- [x] SQL Analysis
- [x] Python ETL
- [x] Pandas Transformations
- [x] Data Quality Checks
- [x] Data Warehouse
- [ ] Incremental ETL
- [ ] Docker
- [ ] Apache Spark
- [ ] Apache Airflow

## 👨‍💻 Author

KHALID CHABAB

Data Engineering Portfolio Project