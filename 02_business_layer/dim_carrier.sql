-- ============================================================
-- FILE: dim_carrier.sql
-- PURPOSE:
-- Build carrier dimension.
-- ============================================================

DROP TABLE IF EXISTS dim_carrier;

CREATE TABLE dim_carrier AS
WITH cleaned AS (
    SELECT
        TRIM(carrier_id) AS carrier_id,
        TRIM(carrier_name) AS carrier_name,
        TRIM(transport_mode) AS transport_mode,
        COALESCE(active_flag, 1) AS active_flag,
        ROW_NUMBER() OVER (
            PARTITION BY carrier_id
            ORDER BY load_ts DESC
        ) AS rn
    FROM raw_carrier_master
    WHERE carrier_id IS NOT NULL
)
SELECT
    carrier_id,
    carrier_name,
    transport_mode,
    active_flag
FROM cleaned
WHERE rn = 1;
