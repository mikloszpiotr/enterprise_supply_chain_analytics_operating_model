-- ============================================================
-- FACT TABLE: fact_demand_signal
-- PURPOSE:
-- Compare forecast demand against actual shipped demand proxy.
-- NOTE:
-- Actual demand is approximated here from shipped quantities tied
-- to orders. Replace with actual sales demand if available.
-- ============================================================

DROP TABLE IF EXISTS fact_demand_signal;

CREATE TABLE fact_demand_signal AS
WITH forecast_base AS (
    SELECT
        forecast_date AS demand_date,
        product_id,
        location_id,
        SUM(forecast_qty) AS forecast_qty
    FROM stg_forecast
    GROUP BY forecast_date, product_id, location_id
),
actual_demand AS (
    SELECT
        shipment_date AS demand_date,
        product_id,
        origin_location_id AS location_id,
        SUM(shipped_qty) AS actual_demand_qty
    FROM stg_shipments
    GROUP BY shipment_date, product_id, origin_location_id
)
SELECT
    COALESCE(f.demand_date, a.demand_date) AS demand_date,
    COALESCE(f.product_id, a.product_id) AS product_id,
    COALESCE(f.location_id, a.location_id) AS location_id,
    COALESCE(f.forecast_qty, 0) AS forecast_qty,
    COALESCE(a.actual_demand_qty, 0) AS actual_demand_qty,
    COALESCE(f.forecast_qty, 0) - COALESCE(a.actual_demand_qty, 0) AS forecast_error_qty,
    ABS(COALESCE(f.forecast_qty, 0) - COALESCE(a.actual_demand_qty, 0)) AS absolute_error_qty,
    CASE
        WHEN COALESCE(f.forecast_qty, 0) - COALESCE(a.actual_demand_qty, 0) > 0 THEN 1
        ELSE 0
    END AS bias_flag
FROM forecast_base f
FULL OUTER JOIN actual_demand a
    ON f.demand_date = a.demand_date
   AND f.product_id = a.product_id
   AND f.location_id = a.location_id;
