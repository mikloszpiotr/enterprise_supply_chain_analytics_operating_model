-- ============================================================
-- FILE: mart_supplier_risk.sql
-- PURPOSE:
-- Support supplier escalation based on lead time reliability.
-- ============================================================

DROP TABLE IF EXISTS mart_supplier_risk;

CREATE TABLE mart_supplier_risk AS
SELECT
    year,
    month,
    region,
    product_category,
    total_pos,
    avg_lead_time_deviation,
    late_po_pct,
    CASE
        WHEN late_po_pct > 20 OR avg_lead_time_deviation > 2 THEN 'ESCALATE_SUPPLIER'
        WHEN late_po_pct > 10 THEN 'WATCHLIST'
        ELSE 'STABLE'
    END AS supplier_risk_flag
FROM kpi_lead_time_variability;
