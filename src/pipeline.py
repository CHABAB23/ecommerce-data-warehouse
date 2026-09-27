import subprocess
import sys


# ============================================================
# ETL PIPELINE
# ============================================================

SCRIPTS = [
    "src/extract/extract_data.py",

    "src/transform/transform_customers.py",
    "src/transform/transform_products.py",
    "src/transform/transform_orders.py",
    "src/transform/transform_order_items.py",
    "src/transform/transform_payments.py",
    "src/transform/transform_shipments.py",
]


def run_script(script):
    print("\n" + "=" * 60)
    print(f"Running: {script}")
    print("=" * 60)

    result = subprocess.run(
        [sys.executable, script],
        check=False
    )

    if result.returncode != 0:
        print(f"\nERROR: {script} failed.")
        sys.exit(result.returncode)


def main():
    print("\nStarting E-Commerce ETL Pipeline...\n")

    for script in SCRIPTS:
        run_script(script)

    print("\n" + "=" * 60)
    print("ETL PIPELINE COMPLETED SUCCESSFULLY")
    print("=" * 60)


if __name__ == "__main__":
    main()