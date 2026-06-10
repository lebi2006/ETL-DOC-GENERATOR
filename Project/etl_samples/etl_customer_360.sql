-- etl_customer_360.sql
-- Style: Heavy CTE-based SQL with window functions and complex aggregations

-- ============================================================
-- STEP 1: CLEAN RAW CUSTOMER TRANSACTIONS
-- ============================================================

DROP TABLE IF EXISTS stg_clean_transactions;

CREATE TABLE stg_clean_transactions AS
WITH ranked AS (
    SELECT
        t.*,
        ROW_NUMBER() OVER (
            PARTITION BY t.transaction_id
            ORDER BY t.created_at DESC
        ) AS rn
    FROM raw_transactions t
    WHERE t.status != 'CANCELLED'
      AND t.amount > 0
),
deduped AS (
    SELECT * FROM ranked WHERE rn = 1
)
SELECT
    d.transaction_id,
    d.customer_id,
    d.product_id,
    d.amount,
    d.quantity,
    d.transaction_date,
    d.channel,
    UPPER(TRIM(d.region))         AS region,
    LOWER(TRIM(d.payment_method)) AS payment_method
FROM deduped d;


-- ============================================================
-- STEP 2: BUILD CUSTOMER LIFETIME VALUE
-- ============================================================

DROP TABLE IF EXISTS stg_customer_ltv;

CREATE TABLE stg_customer_ltv AS
WITH monthly_spend AS (
    SELECT
        customer_id,
        strftime('%Y-%m', transaction_date) AS month,
        SUM(amount)                          AS monthly_revenue,
        COUNT(transaction_id)                AS monthly_orders
    FROM stg_clean_transactions
    GROUP BY customer_id, strftime('%Y-%m', transaction_date)
),
cumulative AS (
    SELECT
        customer_id,
        month,
        monthly_revenue,
        monthly_orders,
        SUM(monthly_revenue) OVER (
            PARTITION BY customer_id
            ORDER BY month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue,
        AVG(monthly_revenue) OVER (
            PARTITION BY customer_id
            ORDER BY month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_3m_avg
    FROM monthly_spend
)
SELECT
    customer_id,
    MAX(cumulative_revenue)              AS lifetime_value,
    SUM(monthly_orders)                  AS total_orders,
    AVG(rolling_3m_avg)                  AS avg_monthly_spend,
    COUNT(DISTINCT month)                AS active_months
FROM cumulative
GROUP BY customer_id;


-- ============================================================
-- STEP 3: SEGMENT CUSTOMERS
-- ============================================================

DROP TABLE IF EXISTS dim_customer_segments;

CREATE TABLE dim_customer_segments AS
WITH percentiles AS (
    SELECT
        customer_id,
        lifetime_value,
        total_orders,
        NTILE(4) OVER (ORDER BY lifetime_value DESC) AS value_quartile,
        NTILE(4) OVER (ORDER BY total_orders DESC)   AS frequency_quartile
    FROM stg_customer_ltv
)
SELECT
    p.customer_id,
    c.customer_name,
    c.email,
    c.region,
    p.lifetime_value,
    p.total_orders,
    CASE
        WHEN p.value_quartile = 1 AND p.frequency_quartile = 1 THEN 'Champion'
        WHEN p.value_quartile <= 2 AND p.frequency_quartile <= 2 THEN 'Loyal'
        WHEN p.value_quartile = 1 THEN 'Big Spender'
        WHEN p.frequency_quartile = 1 THEN 'Frequent Buyer'
        ELSE 'Regular'
    END AS segment,
    CURRENT_TIMESTAMP AS etl_timestamp
FROM percentiles p
JOIN customers c ON p.customer_id = c.customer_id;


-- ============================================================
-- STEP 4: FINAL REPORTING TABLE
-- ============================================================

DROP TABLE IF EXISTS rpt_customer_360;

CREATE TABLE rpt_customer_360 AS
SELECT
    s.customer_id,
    s.customer_name,
    s.email,
    s.region,
    s.segment,
    s.lifetime_value,
    s.total_orders,
    l.avg_monthly_spend,
    l.active_months,
    MAX(t.transaction_date) AS last_purchase_date,
    COUNT(DISTINCT t.product_id) AS unique_products_bought,
    CURRENT_TIMESTAMP AS etl_loaded_at
FROM dim_customer_segments s
JOIN stg_customer_ltv l ON s.customer_id = l.customer_id
JOIN stg_clean_transactions t ON s.customer_id = t.customer_id
GROUP BY
    s.customer_id, s.customer_name, s.email,
    s.region, s.segment, s.lifetime_value,
    s.total_orders, l.avg_monthly_spend, l.active_months;
