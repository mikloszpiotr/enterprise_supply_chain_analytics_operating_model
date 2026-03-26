-- ============================================================
-- FILE: kpi_stockout_risk.sql
-- PURPOSE:
-- Quantify shortage risk share by month, region, and category.
-- ============================================================

DROP TABLE IF EXISTS kpi_stockout_risk;

CREATE TABLE kpi_stockout_risk AS
SELECT
    dd.year,
    dd.month,
    dl.region,
    dp.category AS product_category,
    COUNT(*) AS inventory_record_count,
    SUM(shortage_risk_flag) AS shortage_risk_sku_count,
    ROUND(SUM(shortage_risk_flag) * 100.0 / NULLIF(COUNT(*), 0), 2) AS shortage_risk_pct
FROM fact_inventory_position fip
LEFT JOIN dim_date dd
    ON fip.snapshot_date = dd.date
LEFT JOIN dim_location dl
    ON fip.location_id = dl.location_id
LEFT JOIN dim_product dp
    ON fip.product_id = dp.product_id
GROUP BY dd.year, dd.month, dl.region, dp.category;
