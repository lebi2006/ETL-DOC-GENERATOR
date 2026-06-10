# etl_hr_payroll.py
# Style: Functional programming with helper functions and decorators

import pandas as pd
import sqlite3
import functools
import time


def timer(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        print(f"[{func.__name__}] completed in {time.time() - start:.2f}s")
        return result
    return wrapper


@timer
def extract_employees():
    return pd.read_csv("data/employees.csv")


@timer
def extract_attendance():
    return pd.read_csv("data/attendance.csv")


@timer
def extract_deductions():
    return pd.read_excel("data/deductions.xlsx")


def calculate_gross_pay(row):
    base = row["base_salary"]
    overtime = row.get("overtime_hours", 0) * row.get("hourly_rate", 0)
    return base + overtime


def calculate_net_pay(gross, deduction):
    tax = gross * 0.18
    return gross - tax - deduction


@timer
def transform(employees, attendance, deductions):
    df = pd.merge(employees, attendance, on="employee_id", how="inner")
    df = pd.merge(df, deductions, on="employee_id", how="left")
    df["deduction_amount"] = df["deduction_amount"].fillna(0)
    df["gross_pay"] = df.apply(calculate_gross_pay, axis=1)
    df["net_pay"] = df.apply(
        lambda row: calculate_net_pay(
            row["gross_pay"], row["deduction_amount"]
        ), axis=1
    )
    df["attendance_pct"] = (
        df["days_present"] / df["working_days"] * 100
    ).round(2)
    df = df.drop_duplicates(subset=["employee_id"])
    df = df.sort_values("net_pay", ascending=False)
    return df


@timer
def load(df, table_name="payroll_report"):
    conn = sqlite3.connect("hr.db")
    df.to_sql(table_name, conn, if_exists="replace", index=False)
    conn.close()
    print(f"Loaded {len(df)} records into {table_name}.")


def run_pipeline():
    employees = extract_employees()
    attendance = extract_attendance()
    deductions = extract_deductions()
    result = transform(employees, attendance, deductions)
    load(result)


if __name__ == "__main__":
    run_pipeline()
