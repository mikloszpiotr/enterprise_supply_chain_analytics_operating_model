-- ============================================================
-- FILE: dim_customer.sql
-- PURPOSE:
-- Build customer dimension.
-- ============================================================

DROP TABLE IF EXISTS dim_customer;

CREATE TABLE dim_customer AS
WITH cleaned AS (
    SELECT
        TRIM(customer_id) AS customer_id,
        TRIM(customer_name) AS customer_name,
        TRIM(segment) AS segment,
        TRIM(region) AS region,
        TRIM(country) AS country,
        COALESCE(active_flag, 1) AS active_flag,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY load_ts DESC
        ) AS rn
    FROM raw_customer_master
    WHERE customer_id IS NOT NULL
)
SELECT
    customer_id,
    customer_name,
    segment,
    region,
    country,
    active_flag
FROM cleaned
WHERE rn = 1;
