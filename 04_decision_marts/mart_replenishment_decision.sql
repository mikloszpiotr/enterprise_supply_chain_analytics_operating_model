-- ============================================================
-- FILE: mart_replenishment_decision.sql
-- PURPOSE:
-- Identify replenishment priorities using stock risk and service.
-- ============================================================

DROP TABLE IF EXISTS mart_replenishment_decision;

CREATE TABLE mart_replenishment_decision AS
WITH inv AS (
    SELECT
        year,
        month,
        region,
        product_category,
        shortage_risk_pct,
        avg_days_of_coverage
    FROM mart_inventory_decision
),
svc AS (
    SELECT
        year,
        month,
        region,
        product_category,
        otif_pct
    FROM kpi_service_level
)
SELECT
    COALESCE(i.year, s.year) AS year,
    COALESCE(i.month, s.month) AS month,
    COALESCE(i.region, s.region) AS region,
    COALESCE(i.product_category, s.product_category) AS product_category,
    COALESCE(i.shortage_risk_pct, 0) AS shortage_risk_pct,
    COALESCE(i.avg_days_of_coverage, 0) AS avg_days_of_coverage,
    COALESCE(s.otif_pct, 0) AS otif_pct,
    CASE
        WHEN COALESCE(i.shortage_risk_pct, 0) > 20 AND COALESCE(s.otif_pct, 100) < 92
            THEN 'URGENT_REPLENISH'
        WHEN COALESCE(i.shortage_risk_pct, 0) > 10
            THEN 'REVIEW_REPLENISHMENT'
        WHEN COALESCE(i.avg_days_of_coverage, 0) > 40 AND COALESCE(s.otif_pct, 0) >= 95
            THEN 'DEFER_REPLENISHMENT'
        ELSE 'BALANCED'
    END AS replenishment_priority
FROM inv i
FULL OUTER JOIN svc s
    ON i.year = s.year
   AND i.month = s.month
   AND i.region = s.region
   AND i.product_category = s.product_category;
