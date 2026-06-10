# etl_product_analytics.py
# Style: Config-driven pipeline with explicit error handling and logging

import pandas as pd
import sqlite3
import json
import sys

PIPELINE_CONFIG = {
    "sources": {
        "products": "data/products.csv",
        "orders": "data/orders.csv",
        "returns": "data/returns.csv",
        "categories": "data/categories.csv"
    },
    "target_db": "analytics.db",
    "targets": {
        "product_performance": "product_performance_report",
        "category_summary": "category_summary_report"
    },
    "filters": {
        "min_order_value": 10,
        "exclude_status": ["CANCELLED", "FRAUD"]
    }
}


def load_source(name, path):
    try:
        df = pd.read_csv(path)
        print(f"[EXTRACT] {name}: {len(df)} rows loaded from {path}")
        return df
    except FileNotFoundError:
        print(f"[ERROR] File not found: {path}")
        sys.exit(1)


def validate(df, name, required_cols):
    missing = [c for c in required_cols if c not in df.columns]
    if missing:
        print(f"[VALIDATE] {name} missing columns: {missing}")
        sys.exit(1)
    print(f"[VALIDATE] {name} passed validation.")
    return df


def build_product_performance(products, orders, returns, config):
    min_val = config["filters"]["min_order_value"]
    exclude = config["filters"]["exclude_status"]

    orders_clean = orders[~orders["status"].isin(exclude)]
    orders_clean = orders_clean[orders_clean["order_value"] >= min_val]

    merged = pd.merge(orders_clean, products, on="product_id", how="left")
    merged = pd.merge(
        merged,
        returns[["order_id", "return_reason"]],
        on="order_id",
        how="left"
    )

    merged["is_returned"] = merged["return_reason"].notna().astype(int)
    merged["revenue"] = merged["quantity"] * merged["unit_price"]

    summary = merged.groupby(
        ["product_id", "product_name", "category_id"]
    ).agg(
        total_orders=("order_id", "count"),
        total_revenue=("revenue", "sum"),
        total_returns=("is_returned", "sum"),
        avg_order_value=("order_value", "mean")
    ).reset_index()

    summary["return_rate"] = (
        summary["total_returns"] / summary["total_orders"] * 100
    ).round(2)

    summary["performance_grade"] = summary["total_revenue"].apply(
        lambda x: "A" if x > 50000
        else "B" if x > 20000
        else "C" if x > 5000
        else "D"
    )

    return summary


def build_category_summary(product_performance, categories):
    merged = pd.merge(
        product_performance,
        categories,
        on="category_id",
        how="left"
    )
    return merged.groupby("category_name").agg(
        total_products=("product_id", "count"),
        total_revenue=("total_revenue", "sum"),
        avg_return_rate=("return_rate", "mean")
    ).reset_index()


def load_to_db(df, table_name, db_path):
    try:
        conn = sqlite3.connect(db_path)
        df.to_sql(table_name, conn, if_exists="replace", index=False)
        conn.close()
        print(f"[LOAD] {len(df)} rows loaded into {table_name}")
    except Exception as e:
        print(f"[ERROR] Failed to load {table_name}: {e}")
        sys.exit(1)


def run():
    print("[START] Product Analytics ETL Pipeline")
    print(f"[CONFIG] {json.dumps(PIPELINE_CONFIG['filters'], indent=2)}")

    products = validate(
        load_source("products", PIPELINE_CONFIG["sources"]["products"]),
        "products", ["product_id", "product_name", "unit_price", "category_id"]
    )
    orders = validate(
        load_source("orders", PIPELINE_CONFIG["sources"]["orders"]),
        "orders", ["order_id", "product_id", "quantity", "order_value", "status"]
    )
    returns = load_source("returns", PIPELINE_CONFIG["sources"]["returns"])
    categories = load_source("categories", PIPELINE_CONFIG["sources"]["categories"])

    product_perf = build_product_performance(products, orders, returns, PIPELINE_CONFIG)
    category_summary = build_category_summary(product_perf, categories)

    db = PIPELINE_CONFIG["target_db"]
    load_to_db(product_perf, PIPELINE_CONFIG["targets"]["product_performance"], db)
    load_to_db(category_summary, PIPELINE_CONFIG["targets"]["category_summary"], db)

    print("[DONE] Pipeline completed successfully.")


if __name__ == "__main__":
    run()
