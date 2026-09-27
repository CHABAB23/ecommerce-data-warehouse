import pandas as pd


# ============================================================
# FILE PATHS
# ============================================================

INPUT_FILE = "data/raw/products.csv"
OUTPUT_FILE = "data/processed/products.csv"


# ============================================================
# READ RAW DATA
# ============================================================

products = pd.read_csv(
    INPUT_FILE,
    dtype={
        "product_id": "Int64",
        "product_name": "string",
        "category": "string",
        "price": "float64",
        "stock_quantity": "Int64"
    }
)

print(f"Raw rows: {len(products)}")


# ============================================================
# 1. REMOVE DUPLICATE PRODUCTS
# ============================================================

products = products.drop_duplicates(
    subset=["product_id"]
)


# ============================================================
# 2. CLEAN PRODUCT NAME
# ============================================================

products["product_name"] = (
    products["product_name"]
    .str.strip()
)


# ============================================================
# 3. CLEAN CATEGORY
# ============================================================

products["category"] = (
    products["category"]
    .str.strip()
    .str.title()
)


# ============================================================
# 4. CLEAN PRICE
# ============================================================

products["price"] = pd.to_numeric(
    products["price"],
    errors="coerce"
)


# ============================================================
# 5. CLEAN STOCK QUANTITY
# ============================================================

products["stock_quantity"] = pd.to_numeric(
    products["stock_quantity"],
    errors="coerce"
)


# ============================================================
# 6. CONVERT CREATED_AT
# ============================================================

products["created_at"] = pd.to_datetime(
    products["created_at"],
    errors="coerce"
)


# ============================================================
# 7. DATA QUALITY CHECKS
# ============================================================

print(
    f"Duplicate product IDs: "
    f"{products['product_id'].duplicated().sum()}"
)

print(
    f"Missing product IDs: "
    f"{products['product_id'].isna().sum()}"
)

print(
    f"Missing product names: "
    f"{products['product_name'].isna().sum()}"
)

print(
    f"Invalid prices: "
    f"{products['price'].isna().sum()}"
)

print(
    f"Negative prices: "
    f"{(products['price'] < 0).sum()}"
)

print(
    f"Negative stock quantities: "
    f"{(products['stock_quantity'] < 0).sum()}"
)

print(
    f"Invalid dates: "
    f"{products['created_at'].isna().sum()}"
)


# ============================================================
# 8. SAVE PROCESSED DATA
# ============================================================

products.to_csv(
    OUTPUT_FILE,
    index=False
)


print(
    f"Transformed data saved to: "
    f"{OUTPUT_FILE}"
)