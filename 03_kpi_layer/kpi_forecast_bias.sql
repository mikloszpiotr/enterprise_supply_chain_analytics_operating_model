-- ============================================================
-- FILE: kpi_forecast_bias.sql
-- PURPOSE:
-- Standardize forecast bias by month, region, and category.
-- ============================================================

DROP TABLE IF EXISTS kpi_forecast_bias;

CREATE TABLE kpi_forecast_bias AS
SELECT
    dd.year,
    dd.month,
    dl.region,
    dp.category AS product_category,
    SUM(forecast_qty) AS total_forecast_qty,
    SUM(actual_demand_qty) AS total_actual_demand_qty,
    SUM(forecast_error_qty) AS total_forecast_error_qty,
    CASE
        WHEN SUM(actual_demand_qty) <> 0
            THEN ROUND(SUM(forecast_error_qty) * 100.0 / SUM(actual_demand_qty), 2)
        ELSE NULL
    END AS forecast_bias_pct
FROM fact_demand_signal fds
LEFT JOIN dim_date dd
    ON fds.demand_date = dd.date
LEFT JOIN dim_location dl
    ON fds.location_id = dl.location_id
LEFT JOIN dim_product dp
    ON fds.product_id = dp.product_id
GROUP BY dd.year, dd.month, dl.region, dp.category;
