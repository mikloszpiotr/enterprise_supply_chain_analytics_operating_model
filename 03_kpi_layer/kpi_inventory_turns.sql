-- ============================================================
-- FILE: kpi_inventory_turns.sql
-- PURPOSE:
-- Estimate inventory turns using forecast demand as COGS proxy.
-- NOTE:
-- Replace estimated COGS with actual cost of goods sold when
-- available in production environments.
-- ============================================================

DROP TABLE IF EXISTS kpi_inventory_turns;

CREATE TABLE kpi_inventory_turns AS
WITH inventory_base AS (
    SELECT
        dd.year,
        dd.month,
        dl.region,
        dp.category AS product_category,
        AVG(fip.inventory_value) AS avg_inventory_value,
        SUM(COALESCE(fip.forecast_qty, 0) * COALESCE(dp.standard_cost, 0)) AS estimated_cogs
    FROM fact_inventory_position fip
    LEFT JOIN dim_date dd
        ON fip.snapshot_date = dd.date
    LEFT JOIN dim_location dl
        ON fip.location_id = dl.location_id
    LEFT JOIN dim_product dp
        ON fip.product_id = dp.product_id
    GROUP BY dd.year, dd.month, dl.region, dp.category
)
SELECT
    year,
    month,
    region,
    product_category,
    avg_inventory_value,
    estimated_cogs,
    CASE
        WHEN avg_inventory_value > 0
            THEN ROUND(estimated_cogs * 1.0 / avg_inventory_value, 2)
        ELSE NULL
    END AS inventory_turns
FROM inventory_base;
