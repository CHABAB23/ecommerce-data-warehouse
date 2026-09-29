import pandas as pd
import psycopg2


# --------------------------------------------------
# PostgreSQL connection
# --------------------------------------------------

conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="ecommerce_db",
    user="postgres",
    password="PASSWORD"
)


# --------------------------------------------------
# Get last successful pipeline timestamp
# --------------------------------------------------

control_query = """
SELECT last_run_timestamp
FROM dw.etl_control
WHERE pipeline_name = 'customers';
"""

control_df = pd.read_sql(control_query, conn)

last_run = control_df.iloc[0]["last_run_timestamp"]

print(f"Last successful run: {last_run}")


# --------------------------------------------------
# Extract only new customers
# --------------------------------------------------

query = """
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    city,
    country,
    created_at
FROM customers
WHERE created_at > %s
ORDER BY created_at;
"""

customers = pd.read_sql(
    query,
    conn,
    params=(last_run,)
)


print(f"New customers extracted: {len(customers)}")


# --------------------------------------------------
# Save incremental data
# --------------------------------------------------

OUTPUT_FILE = "data/raw/customers_incremental.csv"

customers.to_csv(
    OUTPUT_FILE,
    index=False
)

print(f"Incremental data saved to: {OUTPUT_FILE}")


conn.close()