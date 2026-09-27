import pandas as pd


# ============================================================
# FILE PATHS
# ============================================================

INPUT_FILE = "data/raw/shipments.csv"
OUTPUT_FILE = "data/processed/shipments.csv"


# ============================================================
# READ RAW DATA
# ============================================================

shipments = pd.read_csv(
    INPUT_FILE,
    dtype={
        "shipment_id": "Int64",
        "order_id": "Int64",
        "carrier": "string",
        "tracking_number": "string"
    }
)

print(f"Raw rows: {len(shipments)}")


# ============================================================
# 1. REMOVE DUPLICATE SHIPMENTS
# ============================================================

shipments = shipments.drop_duplicates(
    subset=["shipment_id"]
)


# ============================================================
# 2. CLEAN CARRIER
# ============================================================

shipments["carrier"] = (
    shipments["carrier"]
    .str.strip()
    .str.title()
)


# ============================================================
# 3. CLEAN TRACKING NUMBER
# ============================================================

shipments["tracking_number"] = (
    shipments["tracking_number"]
    .str.strip()
    .str.upper()
)


# ============================================================
# 4. CONVERT DATES
# ============================================================

shipments["shipped_date"] = pd.to_datetime(
    shipments["shipped_date"],
    errors="coerce"
)

shipments["delivery_date"] = pd.to_datetime(
    shipments["delivery_date"],
    errors="coerce"
)


# ============================================================
# 5. VALIDATE CARRIERS
# ============================================================

allowed_carriers = {
    "Dhl",
    "Amana"
}

invalid_carriers = (
    ~shipments["carrier"].isin(
        allowed_carriers
    )
).sum()


# ============================================================
# 6. DATA QUALITY CHECKS
# ============================================================

print(
    f"Duplicate shipment IDs: "
    f"{shipments['shipment_id'].duplicated().sum()}"
)

print(
    f"Missing shipment IDs: "
    f"{shipments['shipment_id'].isna().sum()}"
)

print(
    f"Missing order IDs: "
    f"{shipments['order_id'].isna().sum()}"
)

print(
    f"Missing tracking numbers: "
    f"{shipments['tracking_number'].isna().sum()}"
)

print(
    f"Invalid carriers: "
    f"{invalid_carriers}"
)

print(
    f"Invalid shipped dates: "
    f"{shipments['shipped_date'].isna().sum()}"
)


# ============================================================
# 7. DELIVERY DATE CHECK
# ============================================================

# A delivery date is allowed to be NULL because
# some shipments have not been delivered yet.

delivered_dates = shipments["delivery_date"].notna()

print(
    f"Missing delivery dates: "
    f"{shipments['delivery_date'].isna().sum()}"
)


# ============================================================
# 8. CHECK DELIVERY DATE LOGIC
# ============================================================

invalid_delivery_dates = (
    delivered_dates
    & (
        shipments["delivery_date"]
        < shipments["shipped_date"]
    )
).sum()

print(
    f"Delivery dates before shipped dates: "
    f"{invalid_delivery_dates}"
)


# ============================================================
# 9. VALIDATE ORDER FOREIGN KEYS
# ============================================================

orders = pd.read_csv(
    "data/processed/orders.csv",
    dtype={
        "order_id": "Int64"
    }
)

invalid_order_ids = (
    ~shipments["order_id"].isin(
        orders["order_id"]
    )
).sum()

print(
    f"Invalid order IDs: "
    f"{invalid_order_ids}"
)


# ============================================================
# 10. SAVE PROCESSED DATA
# ============================================================

shipments.to_csv(
    OUTPUT_FILE,
    index=False
)

print(
    f"Transformed data saved to: "
    f"{OUTPUT_FILE}"
)