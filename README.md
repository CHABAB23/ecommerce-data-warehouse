# E-Commerce Data Warehouse

A hands-on Data Engineering project built with Python, SQL, and PostgreSQL.

## Project Goal

Build an end-to-end e-commerce data platform that demonstrates:

- Relational database design
- SQL
- Data quality
- ETL pipelines
- Data Warehouse modeling
- Python
- Docker
- Apache Spark

## Current Architecture

```text
Customers
    |
    v
Orders
    |
    +------> Payments
    |
    +------> Shipments
    |
    v
Order Items
    |
    v
Products