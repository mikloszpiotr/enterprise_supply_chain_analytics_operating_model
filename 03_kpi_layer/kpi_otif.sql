-- ============================================================
-- FILE: kpi_otif.sql
-- PURPOSE:
-- Standardize OTIF by month, region, customer segment, and category.
-- ============================================================

DROP TABLE IF EXISTS kpi_otif;

CREATE TABLE kpi_otif AS
SELECT
    dd.year,
    dd.month,
    dc.region,
    dc.segment AS customer_segment,
    dp.category AS product_category,
    COUNT(*) AS total_order_lines,
    SUM(otif_flag) AS otif_order_lines,
    ROUND(SUM(otif_flag) * 100.0 / NULLIF(COUNT(*), 0), 2) AS otif_pct
FROM fact_order_fulfillment fof
LEFT JOIN dim_date dd
    ON fof.order_date = dd.date
LEFT JOIN dim_customer dc
    ON fof.customer_id = dc.customer_id
LEFT JOIN dim_product dp
    ON fof.product_id = dp.product_id
GROUP BY dd.year, dd.month, dc.region, dc.segment, dp.category;
