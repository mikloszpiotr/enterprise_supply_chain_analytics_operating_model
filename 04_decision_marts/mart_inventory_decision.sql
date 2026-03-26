-- ============================================================
-- FILE: mart_inventory_decision.sql
-- PURPOSE:
-- Provide inventory review mart for working capital and stock risk.
-- ============================================================

DROP TABLE IF EXISTS mart_inventory_decision;

CREATE TABLE mart_inventory_decision AS
WITH base AS (
    SELECT
        dd.year,
        dd.month,
        dl.region,
        dp.category AS product_category,
        AVG(fip.inventory_value) AS avg_inventory_value,
        AVG(fip.days_of_coverage) AS avg_days_of_coverage,
        ROUND(SUM(fip.shortage_risk_flag) * 100.0 / NULLIF(COUNT(*), 0), 2) AS shortage_risk_pct,
        ROUND(SUM(fip.excess_inventory_flag) * 100.0 / NULLIF(COUNT(*), 0), 2) AS excess_inventory_pct
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
    avg_days_of_coverage,
    shortage_risk_pct,
    excess_inventory_pct,
    CASE
        WHEN shortage_risk_pct > 15 THEN 'PRIORITIZE_SUPPLY'
        WHEN excess_inventory_pct > 20 AND avg_days_of_coverage > 30 THEN 'REDUCE_INVENTORY'
        ELSE 'MONITOR'
    END AS inventory_decision_flag
FROM base;
