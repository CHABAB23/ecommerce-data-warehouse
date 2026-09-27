import pandas as pd


# Input and output paths
INPUT_FILE = "data/raw/customers.csv"
OUTPUT_FILE = "data/processed/customers.csv"


# Read raw customers data
customers = pd.read_csv(
    INPUT_FILE,
    dtype={"phone": "string"}
)

print(f"Raw rows: {len(customers)}")


# --------------------------------------------------
# 1. Remove duplicate customers
# --------------------------------------------------

customers = customers.drop_duplicates(subset=["customer_id"])


# --------------------------------------------------
# 2. Clean names
# --------------------------------------------------

customers["first_name"] = (
    customers["first_name"]
    .astype(str)
    .str.strip()
    .str.title()
)

customers["last_name"] = (
    customers["last_name"]
    .astype(str)
    .str.strip()
    .str.title()
)


# --------------------------------------------------
# 3. Clean email
# --------------------------------------------------

customers["email"] = (
    customers["email"]
    .astype(str)
    .str.strip()
    .str.lower()
)


# --------------------------------------------------
# 4. Clean phone
# --------------------------------------------------

customers["phone"] = (
    customers["phone"]
    .astype(str)
    .str.strip()
)

# Restore Moroccan leading zero if it was removed
customers["phone"] = customers["phone"].apply(
    lambda phone: (
        "0" + phone
        if phone.isdigit() and len(phone) == 9
        else phone
    )
)


# --------------------------------------------------
# 5. Normalize location
# --------------------------------------------------

customers["city"] = (
    customers["city"]
    .astype(str)
    .str.strip()
    .str.title()
)

customers["country"] = (
    customers["country"]
    .astype(str)
    .str.strip()
    .str.title()
)


# --------------------------------------------------
# 6. Convert created_at to datetime
# --------------------------------------------------

customers["created_at"] = pd.to_datetime(
    customers["created_at"],
    errors="coerce"
)


# --------------------------------------------------
# 7. Data quality checks
# --------------------------------------------------

print(f"Rows after transformation: {len(customers)}")

print(
    f"Duplicate customer IDs: "
    f"{customers['customer_id'].duplicated().sum()}"
)

print(
    f"Missing emails: "
    f"{customers['email'].isna().sum()}"
)

print(
    f"Invalid dates: "
    f"{customers['created_at'].isna().sum()}"
)


# --------------------------------------------------
# 8. Save transformed data
# --------------------------------------------------

customers.to_csv(
    OUTPUT_FILE,
    index=False
)

print(f"Transformed data saved to: {OUTPUT_FILE}")