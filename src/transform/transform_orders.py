import pandas as pd


# ============================================================
# FILE PATHS
# ============================================================

INPUT_FILE = "data/raw/orders.csv"
OUTPUT_FILE = "data/processed/orders.csv"


# ============================================================
# READ RAW DATA
# ============================================================

orders = pd.read_csv(
    INPUT_FILE,
    dtype={
        "order_id": "Int64",
        "customer_id": "Int64",
        "status": "string"
    }
)

print(f"Raw rows: {len(orders)}")


# ============================================================
# 1. REMOVE DUPLICATE ORDERS
# ============================================================

orders = orders.drop_duplicates(
    subset=["order_id"]
)


# ============================================================
# 2. CLEAN STATUS
# ============================================================

orders["status"] = (
    orders["status"]
    .str.strip()
    .str.title()
)


# ============================================================
# 3. CONVERT ORDER DATE
# ============================================================

orders["order_date"] = pd.to_datetime(
    orders["order_date"],
    errors="coerce"
)


# ============================================================
# 4. VALIDATE ORDER STATUS
# ============================================================

allowed_statuses = {
    "Pending",
    "Shipped",
    "Delivered",
    "Cancelled"
}

invalid_statuses = (
    ~orders["status"].isin(allowed_statuses)
).sum()


# ============================================================
# 5. DATA QUALITY CHECKS
# ============================================================

print(
    f"Duplicate order IDs: "
    f"{orders['order_id'].duplicated().sum()}"
)

print(
    f"Missing order IDs: "
    f"{orders['order_id'].isna().sum()}"
)

print(
    f"Missing customer IDs: "
    f"{orders['customer_id'].isna().sum()}"
)

print(
    f"Invalid order dates: "
    f"{orders['order_date'].isna().sum()}"
)

print(
    f"Invalid order statuses: "
    f"{invalid_statuses}"
)


# ============================================================
# 6. VALIDATE CUSTOMER FOREIGN KEYS
# ============================================================

customers = pd.read_csv(
    "data/processed/customers.csv",
    dtype={
        "customer_id": "Int64"
    }
)

invalid_customer_ids = (
    ~orders["customer_id"].isin(
        customers["customer_id"]
    )
).sum()

print(
    f"Invalid customer IDs: "
    f"{invalid_customer_ids}"
)


# ============================================================
# 7. SAVE PROCESSED DATA
# ============================================================

orders.to_csv(
    OUTPUT_FILE,
    index=False
)


print(
    f"Transformed data saved to: "
    f"{OUTPUT_FILE}"
)