import pandas as pd


# ============================================================
# FILE PATHS
# ============================================================

INPUT_FILE = "data/raw/payments.csv"
OUTPUT_FILE = "data/processed/payments.csv"


# ============================================================
# READ RAW DATA
# ============================================================

payments = pd.read_csv(
    INPUT_FILE,
    dtype={
        "payment_id": "Int64",
        "order_id": "Int64",
        "payment_method": "string",
        "amount": "float64"
    }
)

print(f"Raw rows: {len(payments)}")


# ============================================================
# 1. REMOVE DUPLICATE PAYMENTS
# ============================================================

payments = payments.drop_duplicates(
    subset=["payment_id"]
)


# ============================================================
# 2. CLEAN PAYMENT METHOD
# ============================================================

payments["payment_method"] = (
    payments["payment_method"]
    .str.strip()
    .str.title()
)


# ============================================================
# 3. CONVERT AMOUNT TO NUMERIC
# ============================================================

payments["amount"] = pd.to_numeric(
    payments["amount"],
    errors="coerce"
)


# ============================================================
# 4. CONVERT PAYMENT DATE
# ============================================================

payments["payment_date"] = pd.to_datetime(
    payments["payment_date"],
    errors="coerce"
)


# ============================================================
# 5. VALIDATE PAYMENT METHODS
# ============================================================

allowed_payment_methods = {
    "Credit Card",
    "Paypal",
    "Cash On Delivery"
}

invalid_payment_methods = (
    ~payments["payment_method"].isin(
        allowed_payment_methods
    )
).sum()


# ============================================================
# 6. DATA QUALITY CHECKS
# ============================================================

print(
    f"Duplicate payment IDs: "
    f"{payments['payment_id'].duplicated().sum()}"
)

print(
    f"Missing payment IDs: "
    f"{payments['payment_id'].isna().sum()}"
)

print(
    f"Missing order IDs: "
    f"{payments['order_id'].isna().sum()}"
)

print(
    f"Missing payment methods: "
    f"{payments['payment_method'].isna().sum()}"
)

print(
    f"Invalid payment methods: "
    f"{invalid_payment_methods}"
)

print(
    f"Invalid amounts: "
    f"{payments['amount'].isna().sum()}"
)

print(
    f"Negative amounts: "
    f"{(payments['amount'] < 0).sum()}"
)

print(
    f"Invalid payment dates: "
    f"{payments['payment_date'].isna().sum()}"
)


# ============================================================
# 7. VALIDATE ORDER FOREIGN KEYS
# ============================================================

orders = pd.read_csv(
    "data/processed/orders.csv",
    dtype={
        "order_id": "Int64"
    }
)

invalid_order_ids = (
    ~payments["order_id"].isin(
        orders["order_id"]
    )
).sum()

print(
    f"Invalid order IDs: "
    f"{invalid_order_ids}"
)


# ============================================================
# 8. SAVE PROCESSED DATA
# ============================================================

payments.to_csv(
    OUTPUT_FILE,
    index=False
)

print(
    f"Transformed data saved to: "
    f"{OUTPUT_FILE}"
)