import os

import pandas as pd
from sqlalchemy import create_engine
from dotenv import load_dotenv


# --------------------------------------------------
# Load environment variables
# --------------------------------------------------

load_dotenv()


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
# Get last successful pipeline timestamp
# --------------------------------------------------

control_query = """
SELECT last_run_timestamp
FROM dw.etl_control
WHERE pipeline_name = 'customers';
"""

control_df = pd.read_sql(
    control_query,
    engine
)

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
WHERE created_at > %(last_run)s
ORDER BY created_at;
"""

customers = pd.read_sql(
    query,
    engine,
    params={"last_run": last_run}
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


# --------------------------------------------------
# Close SQLAlchemy engine
# --------------------------------------------------

engine.dispose()