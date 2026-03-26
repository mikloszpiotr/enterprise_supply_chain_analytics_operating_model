-- ============================================================
-- FILE: stg_returns.sql
-- PURPOSE:
-- Standardize returns data linked to order lines.
-- ============================================================

DROP TABLE IF EXISTS stg_returns;

CREATE TABLE stg_returns AS
WITH cleaned AS (
    SELECT
        TRIM(return_id) AS return_id,
        TRIM(order_id) AS order_id,
        TRIM(order_line_id) AS order_line_id,
        CAST(return_date AS DATE) AS return_date,
        COALESCE(return_qty, 0) AS return_qty,
        source_system,
        load_ts,
        ROW_NUMBER() OVER (
            PARTITION BY return_id
            ORDER BY load_ts DESC
        ) AS rn
    FROM raw_returns
    WHERE return_id IS NOT NULL
)
SELECT
    return_id,
    order_id,
    order_line_id,
    return_date,
    return_qty,
    source_system,
    load_ts
FROM cleaned
WHERE rn = 1;
