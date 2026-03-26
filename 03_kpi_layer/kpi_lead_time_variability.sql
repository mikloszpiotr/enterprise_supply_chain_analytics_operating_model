-- ============================================================
-- FILE: kpi_lead_time_variability.sql
-- PURPOSE:
-- Standardize supplier reliability by month, region, and category.
-- ============================================================

DROP TABLE IF EXISTS kpi_lead_time_variability;

CREATE TABLE kpi_lead_time_variability AS
SELECT
    dd.year,
    dd.month,
    dl.region,
    dp.category AS product_category,
    COUNT(DISTINCT fpr.supplier_id) AS supplier_count,
    COUNT(*) AS total_pos,
    ROUND(AVG(COALESCE(fpr.lead_time_deviation, 0)), 2) AS avg_lead_time_deviation,
    ROUND(SUM(late_po_flag) * 100.0 / NULLIF(COUNT(*), 0), 2) AS late_po_pct
FROM fact_procurement_reliability fpr
LEFT JOIN dim_date dd
    ON fpr.order_date = dd.date
LEFT JOIN dim_location dl
    ON fpr.location_id = dl.location_id
LEFT JOIN dim_product dp
    ON fpr.product_id = dp.product_id
GROUP BY dd.year, dd.month, dl.region, dp.category;
