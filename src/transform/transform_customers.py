import pandas as pd


# ============================================================
# FILE PATHS
# ============================================================

INPUT_FILE = "data/raw/customers.csv"
OUTPUT_FILE = "data/processed/customers.csv"


# ============================================================
# READ RAW DATA
# ============================================================

customers = pd.read_csv(
    INPUT_FILE,
    dtype={
        "customer_id": "Int64",
        "first_name": "string",
        "last_name": "string",
        "email": "string",
        "phone": "string",
        "city": "string",
        "country": "string"
    }
)

print(f"Raw rows: {len(customers)}")


# ============================================================
# 1. REMOVE DUPLICATE CUSTOMERS
# ============================================================

customers = customers.drop_duplicates(
    subset=["customer_id"]
)


# ============================================================
# 2. CLEAN NAMES
# ============================================================

customers["first_name"] = (
    customers["first_name"]
    .str.strip()
    .str.title()
)

customers["last_name"] = (
    customers["last_name"]
    .str.strip()
    .str.title()
)


# ============================================================
# 3. NORMALIZE EMAIL
# ============================================================

customers["email"] = (
    customers["email"]
    .str.strip()
    .str.lower()
)


# ============================================================
# 4. CLEAN PHONE
# ============================================================

customers["phone"] = (
    customers["phone"]
    .str.strip()
)

# Restore Moroccan leading zero
# if the phone contains 9 digits.

customers["phone"] = customers["phone"].apply(
    lambda phone: (
        "0" + phone
        if pd.notna(phone)
        and phone.isdigit()
        and len(phone) == 9
        else phone
    )
)


# ============================================================
# 5. NORMALIZE LOCATION
# ============================================================

customers["city"] = (
    customers["city"]
    .str.strip()
    .str.title()
)

customers["country"] = (
    customers["country"]
    .str.strip()
    .str.title()
)


# ============================================================
# 6. CONVERT CREATED_AT
# ============================================================

customers["created_at"] = pd.to_datetime(
    customers["created_at"],
    errors="coerce"
)


# ============================================================
# 7. DATA QUALITY CHECKS
# ============================================================

print(
    f"Duplicate customer IDs: "
    f"{customers['customer_id'].duplicated().sum()}"
)

print(
    f"Missing customer IDs: "
    f"{customers['customer_id'].isna().sum()}"
)

print(
    f"Missing emails: "
    f"{customers['email'].isna().sum()}"
)

print(
    f"Invalid dates: "
    f"{customers['created_at'].isna().sum()}"
)


# ============================================================
# 8. SAVE PROCESSED DATA
# ============================================================

customers.to_csv(
    OUTPUT_FILE,
    index=False
)

print(
    f"Transformed data saved to: "
    f"{OUTPUT_FILE}"
)