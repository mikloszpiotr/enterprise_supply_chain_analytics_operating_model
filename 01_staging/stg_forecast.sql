-- ============================================================
-- FILE: stg_forecast.sql
-- PURPOSE:
-- Standardize forecast input at date-product-location grain.
-- ============================================================

DROP TABLE IF EXISTS stg_forecast;

CREATE TABLE stg_forecast AS
WITH cleaned AS (
    SELECT
        CAST(forecast_date AS DATE) AS forecast_date,
        TRIM(product_id) AS product_id,
        TRIM(location_id) AS location_id,
        COALESCE(forecast_qty, 0) AS forecast_qty,
        source_system,
        load_ts,
        ROW_NUMBER() OVER (
            PARTITION BY forecast_date, product_id, location_id
            ORDER BY load_ts DESC
        ) AS rn
    FROM raw_forecast
    WHERE forecast_date IS NOT NULL
      AND product_id IS NOT NULL
      AND location_id IS NOT NULL
)
SELECT
    forecast_date,
    product_id,
    location_id,
    forecast_qty,
    source_system,
    load_ts
FROM cleaned
WHERE rn = 1;
