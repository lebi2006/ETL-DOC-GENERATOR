-- etl_finance_summary.sql
-- Style: Simple procedural SQL — INSERT INTO ... SELECT pattern
-- Common in legacy enterprise systems and data warehouses

-- ============================================================
-- STEP 1: STAGING — Load raw finance data
-- ============================================================

DROP TABLE IF EXISTS stg_raw_expenses;

CREATE TABLE stg_raw_expenses (
    expense_id      INTEGER,
    department_id   INTEGER,
    category        TEXT,
    amount          REAL,
    expense_date    TEXT,
    approved_by     TEXT,
    vendor_name     TEXT
);

INSERT INTO stg_raw_expenses
SELECT
    expense_id,
    department_id,
    UPPER(category)         AS category,
    amount,
    expense_date,
    approved_by,
    TRIM(vendor_name)       AS vendor_name
FROM raw_expenses
WHERE amount > 0
  AND expense_date IS NOT NULL;


-- ============================================================
-- STEP 2: STAGING — Load department master
-- ============================================================

DROP TABLE IF EXISTS stg_departments;

CREATE TABLE stg_departments (
    department_id   INTEGER,
    department_name TEXT,
    cost_center     TEXT,
    manager         TEXT,
    budget          REAL
);

INSERT INTO stg_departments
SELECT
    department_id,
    department_name,
    cost_center,
    manager,
    budget
FROM departments
WHERE is_active = 1;


-- ============================================================
-- STEP 3: TRANSFORM — Monthly expense summary by department
-- ============================================================

DROP TABLE IF EXISTS fact_monthly_expenses;

CREATE TABLE fact_monthly_expenses (
    department_id       INTEGER,
    department_name     TEXT,
    cost_center         TEXT,
    expense_month       TEXT,
    category            TEXT,
    total_expenses      REAL,
    transaction_count   INTEGER,
    avg_expense         REAL,
    budget              REAL,
    budget_utilization  REAL
);

INSERT INTO fact_monthly_expenses
SELECT
    d.department_id,
    d.department_name,
    d.cost_center,
    strftime('%Y-%m', e.expense_date)   AS expense_month,
    e.category,
    SUM(e.amount)                        AS total_expenses,
    COUNT(e.expense_id)                  AS transaction_count,
    ROUND(AVG(e.amount), 2)              AS avg_expense,
    d.budget,
    ROUND(SUM(e.amount) / d.budget * 100, 2) AS budget_utilization
FROM stg_raw_expenses e
JOIN stg_departments d ON e.department_id = d.department_id
GROUP BY
    d.department_id,
    d.department_name,
    d.cost_center,
    strftime('%Y-%m', e.expense_date),
    e.category;


-- ============================================================
-- STEP 4: TRANSFORM — Vendor spend analysis
-- ============================================================

DROP TABLE IF EXISTS fact_vendor_spend;

CREATE TABLE fact_vendor_spend (
    vendor_name         TEXT,
    total_spend         REAL,
    invoice_count       INTEGER,
    departments_served  INTEGER,
    first_invoice       TEXT,
    last_invoice        TEXT,
    vendor_tier         TEXT
);

INSERT INTO fact_vendor_spend
SELECT
    vendor_name,
    SUM(amount)                     AS total_spend,
    COUNT(expense_id)               AS invoice_count,
    COUNT(DISTINCT department_id)   AS departments_served,
    MIN(expense_date)               AS first_invoice,
    MAX(expense_date)               AS last_invoice,
    CASE
        WHEN SUM(amount) >= 100000 THEN 'STRATEGIC'
        WHEN SUM(amount) >= 50000  THEN 'PREFERRED'
        WHEN SUM(amount) >= 10000  THEN 'APPROVED'
        ELSE                            'OCCASIONAL'
    END                             AS vendor_tier
FROM stg_raw_expenses
GROUP BY vendor_name
ORDER BY total_spend DESC;


-- ============================================================
-- STEP 5: FINAL REPORT — Budget vs Actual
-- ============================================================

DROP TABLE IF EXISTS rpt_budget_vs_actual;

CREATE TABLE rpt_budget_vs_actual (
    department_name     TEXT,
    cost_center         TEXT,
    total_budget        REAL,
    total_spent         REAL,
    remaining_budget    REAL,
    utilization_pct     REAL,
    budget_status       TEXT
);

INSERT INTO rpt_budget_vs_actual
SELECT
    d.department_name,
    d.cost_center,
    d.budget                                    AS total_budget,
    COALESCE(SUM(e.amount), 0)                  AS total_spent,
    d.budget - COALESCE(SUM(e.amount), 0)       AS remaining_budget,
    ROUND(
        COALESCE(SUM(e.amount), 0) / d.budget * 100, 2
    )                                           AS utilization_pct,
    CASE
        WHEN COALESCE(SUM(e.amount), 0) > d.budget      THEN 'OVER BUDGET'
        WHEN COALESCE(SUM(e.amount), 0) > d.budget * 0.9 THEN 'AT RISK'
        ELSE                                                  'ON TRACK'
    END                                         AS budget_status
FROM stg_departments d
LEFT JOIN stg_raw_expenses e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name, d.cost_center, d.budget
ORDER BY utilization_pct DESC;
