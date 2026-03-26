-- ============================================================
-- FILE: dim_supplier.sql
-- PURPOSE:
-- Build supplier dimension.
-- ============================================================

DROP TABLE IF EXISTS dim_supplier;

CREATE TABLE dim_supplier AS
WITH cleaned AS (
    SELECT
        TRIM(supplier_id) AS supplier_id,
        TRIM(supplier_name) AS supplier_name,
        TRIM(country) AS country,
        COALESCE(active_flag, 1) AS active_flag,
        ROW_NUMBER() OVER (
            PARTITION BY supplier_id
            ORDER BY load_ts DESC
        ) AS rn
    FROM raw_supplier_master
    WHERE supplier_id IS NOT NULL
)
SELECT
    supplier_id,
    supplier_name,
    country,
    active_flag
FROM cleaned
WHERE rn = 1;
