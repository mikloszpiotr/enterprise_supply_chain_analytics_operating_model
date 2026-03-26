-- ============================================================
-- FILE: dim_location.sql
-- PURPOSE:
-- Build location dimension with region mapping.
-- ============================================================

DROP TABLE IF EXISTS dim_location;

CREATE TABLE dim_location AS
WITH cleaned AS (
    SELECT
        TRIM(location_id) AS location_id,
        TRIM(location_name) AS location_name,
        TRIM(location_type) AS location_type,
        TRIM(region) AS region,
        TRIM(country) AS country,
        COALESCE(active_flag, 1) AS active_flag,
        ROW_NUMBER() OVER (
            PARTITION BY location_id
            ORDER BY load_ts DESC
        ) AS rn
    FROM raw_location_master
    WHERE location_id IS NOT NULL
)
SELECT
    location_id,
    location_name,
    location_type,
    region,
    country,
    active_flag
FROM cleaned
WHERE rn = 1;
