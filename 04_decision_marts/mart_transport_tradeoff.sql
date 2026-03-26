-- ============================================================
-- FILE: mart_transport_tradeoff.sql
-- PURPOSE:
-- Support carrier/lane cost vs service review.
-- ============================================================

DROP TABLE IF EXISTS mart_transport_tradeoff;

CREATE TABLE mart_transport_tradeoff AS
WITH base AS (
    SELECT
        dd.year,
        dd.month,
        dl.region,
        dp.category AS product_category,
        SUM(fte.shipment_cost) AS total_shipment_cost,
        CASE
            WHEN SUM(fte.units_shipped) > 0
                THEN ROUND(SUM(fte.shipment_cost) * 1.0 / SUM(fte.units_shipped), 4)
            ELSE NULL
        END AS transport_cost_per_unit,
        ROUND(SUM(fte.on_time_flag) * 100.0 / NULLIF(COUNT(*), 0), 2) AS transport_on_time_pct,
        ROUND(SUM(fte.premium_freight_flag) * 100.0 / NULLIF(COUNT(*), 0), 2) AS premium_freight_share_pct
    FROM fact_transport_execution fte
    LEFT JOIN dim_date dd
        ON fte.shipment_date = dd.date
    LEFT JOIN dim_location dl
        ON fte.origin_location_id = dl.location_id
    LEFT JOIN dim_product dp
        ON fte.product_id = dp.product_id
    GROUP BY dd.year, dd.month, dl.region, dp.category
)
SELECT
    year,
    month,
    region,
    product_category,
    total_shipment_cost,
    transport_cost_per_unit,
    transport_on_time_pct,
    premium_freight_share_pct,
    CASE
        WHEN transport_on_time_pct >= 95 AND premium_freight_share_pct > 15
            THEN 'SERVICE_MAINTAINED_AT_HIGH_COST'
        WHEN transport_on_time_pct < 90
            THEN 'SERVICE_AT_RISK'
        ELSE 'BALANCED'
    END AS transport_tradeoff_flag
FROM base;
