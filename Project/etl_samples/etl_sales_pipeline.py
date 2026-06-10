# etl_sales_pipeline.py
# Style: Object-Oriented / Class-based ETL

import pandas as pd
import sqlite3
import logging
from datetime import datetime

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class SalesETLPipeline:

    def __init__(self, db_path="sales.db"):
        self.db_path = db_path
        self.conn = None
        self.raw_sales = None
        self.raw_customers = None
        self.transformed = None

    def connect(self):
        self.conn = sqlite3.connect(self.db_path)
        logger.info("Connected to database.")

    def extract(self):
        self.raw_sales = pd.read_csv("data/sales_transactions.csv")
        self.raw_customers = pd.read_csv("data/customers.csv")
        logger.info(f"Extracted {len(self.raw_sales)} sales records.")
        logger.info(f"Extracted {len(self.raw_customers)} customer records.")

    def transform(self):
        df = pd.merge(
            self.raw_sales,
            self.raw_customers,
            on="customer_id",
            how="left"
        )
        df = df.dropna(subset=["amount"])
        df["revenue"] = df["quantity"] * df["unit_price"]
        df["discount_applied"] = df["discount"].fillna(0)
        df["net_revenue"] = df["revenue"] - df["discount_applied"]
        df["sale_month"] = pd.to_datetime(df["sale_date"]).dt.month
        df["sale_year"] = pd.to_datetime(df["sale_date"]).dt.year
        df["customer_segment"] = df["net_revenue"].apply(
            lambda x: "Premium" if x > 1000 else "Standard"
        )
        self.transformed = df
        logger.info(f"Transformed {len(self.transformed)} records.")

    def load(self):
        self.transformed.to_sql(
            "sales_summary",
            self.conn,
            if_exists="replace",
            index=False
        )
        logger.info("Loaded data into sales_summary table.")

    def run(self):
        self.connect()
        self.extract()
        self.transform()
        self.load()
        self.conn.close()
        logger.info("Pipeline complete.")


if __name__ == "__main__":
    pipeline = SalesETLPipeline()
    pipeline.run()
