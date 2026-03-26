-- ============================================================
-- FILE: kpi_service_level.sql
-- PURPOSE:
-- Standardize service KPIs by month, region, and category.
-- ============================================================

DROP TABLE IF EXISTS kpi_service_level;

CREATE TABLE kpi_service_level AS
SELECT
    dd.year,
    dd.month,
    dc.region,
    dp.category AS product_category,
    COUNT(*) AS total_order_lines,
    ROUND(SUM(otif_flag) * 100.0 / NULLIF(COUNT(*), 0), 2) AS otif_pct,
    ROUND(SUM(on_time_flag) * 100.0 / NULLIF(COUNT(*), 0), 2) AS on_time_pct,
    ROUND(SUM(in_full_flag) * 100.0 / NULLIF(COUNT(*), 0), 2) AS in_full_pct
FROM fact_order_fulfillment fof
LEFT JOIN dim_date dd
    ON fof.order_date = dd.date
LEFT JOIN dim_customer dc
    ON fof.customer_id = dc.customer_id
LEFT JOIN dim_product dp
    ON fof.product_id = dp.product_id
GROUP BY dd.year, dd.month, dc.region, dp.category;
