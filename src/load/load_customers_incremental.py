import pandas as pd
import psycopg2


INPUT_FILE = "data/raw/customers_incremental.csv"


# --------------------------------------------------
# 1. Read incremental data
# --------------------------------------------------

customers = pd.read_csv(INPUT_FILE)

print(f"Incremental rows: {len(customers)}")

if customers.empty:
    print("No new customers to load.")
    exit()


# --------------------------------------------------
# 2. Find the newest source timestamp
# --------------------------------------------------

customers["created_at"] = pd.to_datetime(
    customers["created_at"],
    errors="coerce"
)

max_created_at = customers["created_at"].max()

print(f"New watermark: {max_created_at}")


# --------------------------------------------------
# 3. PostgreSQL connection
# --------------------------------------------------

conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="ecommerce_db",
    user="postgres",
    password="PASSWORD"
)

cursor = conn.cursor()


try:

    inserted = 0
    skipped = 0

    # --------------------------------------------------
    # 4. Load customers into dim_customer
    # --------------------------------------------------

    for _, row in customers.iterrows():

        cursor.execute(
            """
            SELECT 1
            FROM dw.dim_customer
            WHERE customer_id = %s;
            """,
            (int(row["customer_id"]),)
        )

        exists = cursor.fetchone()

        if exists:
            skipped += 1
            continue

        cursor.execute(
            """
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
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s);
            """,
            (
                int(row["customer_id"]),
                row["first_name"],
                row["last_name"],
                row["email"],
                row["phone"],
                row["city"],
                row["country"],
                row["created_at"].to_pydatetime()
            )
        )

        inserted += 1

    # --------------------------------------------------
    # 5. Update ETL control
    # --------------------------------------------------

    cursor.execute(
        """
        UPDATE dw.etl_control
        SET last_run_timestamp = %s
        WHERE pipeline_name = 'customers';
        """,
        (max_created_at.to_pydatetime(),)
    )

    # --------------------------------------------------
    # 6. Commit everything together
    # --------------------------------------------------

    conn.commit()

    print(f"Customers inserted: {inserted}")
    print(f"Customers skipped: {skipped}")
    print("ETL control updated.")
    print("Transaction committed successfully.")

except Exception as e:

    # --------------------------------------------------
    # 7. Rollback everything if something fails
    # --------------------------------------------------

    conn.rollback()

    print("ETL transaction failed.")
    print(f"Error: {e}")
    print("Transaction rolled back.")

    raise

finally:

    cursor.close()
    conn.close()