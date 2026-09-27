import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine


# Load environment variables
load_dotenv()


# PostgreSQL configuration
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")


# Create PostgreSQL connection
connection_string = (
    f"postgresql+psycopg2://"
    f"{DB_USER}:{DB_PASSWORD}@"
    f"{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

engine = create_engine(connection_string)


def extract_table(table_name):
    """
    Extract a PostgreSQL table and save it as a CSV file.
    """

    query = f"SELECT * FROM {table_name};"

    df = pd.read_sql(query, engine)

    output_path = f"data/raw/{table_name}.csv"

    df.to_csv(output_path, index=False)

    print(f"{table_name}: {len(df)} rows extracted")


tables = [
    "customers",
    "products",
    "orders",
    "order_items",
    "payments",
    "shipments",
]


for table in tables:
    extract_table(table)

print("All tables extracted successfully.")