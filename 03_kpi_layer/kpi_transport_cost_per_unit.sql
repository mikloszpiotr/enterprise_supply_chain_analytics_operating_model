-- ============================================================
-- FILE: kpi_transport_cost_per_unit.sql
-- PURPOSE:
-- Standardize transport cost efficiency by month, region, and category.
-- ============================================================

DROP TABLE IF EXISTS kpi_transport_cost_per_unit;

CREATE TABLE kpi_transport_cost_per_unit AS
SELECT
    dd.year,
    dd.month,
    dl.region,
    dp.category AS product_category,
    SUM(shipment_cost) AS total_shipment_cost,
    SUM(units_shipped) AS total_units_shipped,
    CASE
        WHEN SUM(units_shipped) > 0
            THEN ROUND(SUM(shipment_cost) * 1.0 / SUM(units_shipped), 4)
        ELSE NULL
    END AS transport_cost_per_unit
FROM fact_transport_execution fte
LEFT JOIN dim_date dd
    ON fte.shipment_date = dd.date
LEFT JOIN dim_location dl
    ON fte.origin_location_id = dl.location_id
LEFT JOIN dim_product dp
    ON fte.product_id = dp.product_id
GROUP BY dd.year, dd.month, dl.region, dp.category;
