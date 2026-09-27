import pandas as pd


# ============================================================
# FILE PATHS
# ============================================================

INPUT_FILE = "data/raw/order_items.csv"
OUTPUT_FILE = "data/processed/order_items.csv"


# ============================================================
# READ RAW DATA
# ============================================================

order_items = pd.read_csv(
    INPUT_FILE,
    dtype={
        "order_item_id": "Int64",
        "order_id": "Int64",
        "product_id": "Int64",
        "quantity": "Int64",
        "unit_price": "float64"
    }
)

print(f"Raw rows: {len(order_items)}")


# ============================================================
# 1. REMOVE DUPLICATE ORDER ITEMS
# ============================================================

order_items = order_items.drop_duplicates(
    subset=["order_item_id"]
)


# ============================================================
# 2. CLEAN NUMERIC COLUMNS
# ============================================================

order_items["quantity"] = pd.to_numeric(
    order_items["quantity"],
    errors="coerce"
)

order_items["unit_price"] = pd.to_numeric(
    order_items["unit_price"],
    errors="coerce"
)


# ============================================================
# 3. DATA QUALITY CHECKS
# ============================================================

print(
    f"Duplicate order item IDs: "
    f"{order_items['order_item_id'].duplicated().sum()}"
)

print(
    f"Missing order item IDs: "
    f"{order_items['order_item_id'].isna().sum()}"
)

print(
    f"Missing order IDs: "
    f"{order_items['order_id'].isna().sum()}"
)

print(
    f"Missing product IDs: "
    f"{order_items['product_id'].isna().sum()}"
)

print(
    f"Invalid quantities: "
    f"{(order_items['quantity'] <= 0).sum()}"
)

print(
    f"Negative unit prices: "
    f"{(order_items['unit_price'] < 0).sum()}"
)


# ============================================================
# 4. VALIDATE ORDER FOREIGN KEYS
# ============================================================

orders = pd.read_csv(
    "data/processed/orders.csv",
    dtype={
        "order_id": "Int64"
    }
)

invalid_order_ids = (
    ~order_items["order_id"].isin(
        orders["order_id"]
    )
).sum()

print(
    f"Invalid order IDs: "
    f"{invalid_order_ids}"
)


# ============================================================
# 5. VALIDATE PRODUCT FOREIGN KEYS
# ============================================================

products = pd.read_csv(
    "data/processed/products.csv",
    dtype={
        "product_id": "Int64"
    }
)

invalid_product_ids = (
    ~order_items["product_id"].isin(
        products["product_id"]
    )
).sum()

print(
    f"Invalid product IDs: "
    f"{invalid_product_ids}"
)


# ============================================================
# 6. SAVE PROCESSED DATA
# ============================================================

order_items.to_csv(
    OUTPUT_FILE,
    index=False
)


print(
    f"Transformed data saved to: "
    f"{OUTPUT_FILE}"
)