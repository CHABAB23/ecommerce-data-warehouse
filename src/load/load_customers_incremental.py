import os

import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv


# --------------------------------------------------
# Load environment variables
# --------------------------------------------------

load_dotenv()


# --------------------------------------------------
# Input file
# --------------------------------------------------

INPUT_FILE = "data/raw/customers_incremental.csv"


# --------------------------------------------------
# Read incremental data
# --------------------------------------------------

customers = pd.read_csv(INPUT_FILE)

print(f"Incremental rows: {len(customers)}")


# --------------------------------------------------
# Stop if there are no new customers
# --------------------------------------------------

if customers.empty:
    print("No new customers to load.")
    exit()


# --------------------------------------------------
# Prepare timestamp
# --------------------------------------------------

customers["created_at"] = pd.to_datetime(
    customers["created_at"],
    errors="coerce"
)

max_created_at = customers["created_at"].max()

print(f"New watermark: {max_created_at}")


# --------------------------------------------------
# PostgreSQL connection
# --------------------------------------------------

DATABASE_URL = (
    f"postgresql+psycopg2://"
    f"{os.getenv('DB_USER')}:"
    f"{os.getenv('DB_PASSWORD')}@"
    f"{os.getenv('DB_HOST')}:"
    f"{os.getenv('DB_PORT')}/"
    f"{os.getenv('DB_NAME')}"
)

engine = create_engine(DATABASE_URL)


# --------------------------------------------------
# Load customers into warehouse
# --------------------------------------------------

inserted = 0
skipped = 0

try:

    with engine.begin() as connection:

        for _, row in customers.iterrows():

            # Check whether customer already exists
            result = connection.execute(
                text("""
                    SELECT 1
                    FROM dw.dim_customer
                    WHERE customer_id = :customer_id;
                """),
                {
                    "customer_id": int(row["customer_id"])
                }
            )

            exists = result.fetchone()

            if exists:
                skipped += 1
                continue

            # Insert new customer
            connection.execute(
                text("""
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
                    VALUES (
                        :customer_id,
                        :first_name,
                        :last_name,
                        :email,
                        :phone,
                        :city,
                        :country,
                        :created_at
                    );
                """),
                {
                    "customer_id": int(row["customer_id"]),
                    "first_name": row["first_name"],
                    "last_name": row["last_name"],
                    "email": row["email"],
                    "phone": row["phone"],
                    "city": row["city"],
                    "country": row["country"],
                    "created_at": row["created_at"].to_pydatetime()
                }
            )

            inserted += 1

        # Update ETL watermark
        connection.execute(
            text("""
                UPDATE dw.etl_control
                SET last_run_timestamp = :last_run_timestamp
                WHERE pipeline_name = 'customers';
            """),
            {
                "last_run_timestamp": max_created_at.to_pydatetime()
            }
        )

    print(f"Customers inserted: {inserted}")
    print(f"Customers skipped: {skipped}")
    print("ETL control updated.")
    print("Transaction committed successfully.")


except Exception as e:

    print(f"Error: {e}")
    print("Transaction rolled back.")
    raise


finally:

    engine.dispose()