-- ============================================================
-- MART: mart_executive_control_tower
-- PURPOSE:
-- Build an executive-level summary mart that combines inventory,
-- customer service, supplier reliability, and transport cost.
-- GRAIN = month + region + product_category
-- ============================================================

DROP TABLE IF EXISTS mart_executive_control_tower;

CREATE TABLE mart_executive_control_tower AS
WITH inventory_base AS (
    SELECT
        dd.year,
        dd.month,
        dl.region,
        dp.category AS product_category,
        AVG(fip.inventory_value) AS avg_inventory_value,
        AVG(fip.days_of_coverage) AS avg_days_of_coverage,
        SUM(fip.shortage_risk_flag) AS shortage_risk_sku_count,
        SUM(fip.excess_inventory_flag) AS excess_inventory_sku_count,
        COUNT(*) AS inventory_record_count
    FROM fact_inventory_position fip
    LEFT JOIN dim_date dd
        ON fip.snapshot_date = dd.date
    LEFT JOIN dim_location dl
        ON fip.location_id = dl.location_id
    LEFT JOIN dim_product dp
        ON fip.product_id = dp.product_id
    GROUP BY dd.year, dd.month, dl.region, dp.category
),
service_base AS (
    SELECT
        dd.year,
        dd.month,
        dc.region,
        dp.category AS product_category,
        COUNT(*) AS total_order_lines,
        SUM(fof.on_time_flag) AS on_time_order_lines,
        SUM(fof.in_full_flag) AS in_full_order_lines,
        SUM(fof.otif_flag) AS otif_order_lines,
        SUM(CASE WHEN fof.service_failure_reason = 'LATE' THEN 1 ELSE 0 END) AS late_only_count,
        SUM(CASE WHEN fof.service_failure_reason = 'QTY_SHORT' THEN 1 ELSE 0 END) AS qty_short_count,
        SUM(CASE WHEN fof.service_failure_reason = 'LATE_AND_SHORT' THEN 1 ELSE 0 END) AS late_and_short_count,
        SUM(CASE WHEN fof.service_failure_reason = 'NOT_SHIPPED' THEN 1 ELSE 0 END) AS not_shipped_count
    FROM fact_order_fulfillment fof
    LEFT JOIN dim_date dd
        ON fof.order_date = dd.date
    LEFT JOIN dim_customer dc
        ON fof.customer_id = dc.customer_id
    LEFT JOIN dim_product dp
        ON fof.product_id = dp.product_id
    GROUP BY dd.year, dd.month, dc.region, dp.category
),
supplier_base AS (
    SELECT
        dd.year,
        dd.month,
        dl.region,
        dp.category AS product_category,
        COUNT(*) AS total_pos,
        AVG(fpr.lead_time_deviation) AS avg_lead_time_deviation,
        SUM(CASE WHEN fpr.lead_time_deviation > 2 THEN 1 ELSE 0 END) AS late_po_count
    FROM fact_procurement_reliability fpr
    LEFT JOIN dim_date dd
        ON fpr.order_date = dd.date
    LEFT JOIN dim_location dl
        ON fpr.location_id = dl.location_id
    LEFT JOIN dim_product dp
        ON fpr.product_id = dp.product_id
    GROUP BY dd.year, dd.month, dl.region, dp.category
),
transport_base AS (
    SELECT
        dd.year,
        dd.month,
        dlo.region,
        dp.category AS product_category,
        COUNT(*) AS total_shipments,
        AVG(fte.shipment_cost) AS avg_shipment_cost,
        SUM(fte.shipment_cost) AS total_shipment_cost,
        AVG(fte.transit_time) AS avg_transit_time,
        SUM(CASE WHEN fte.on_time_flag = 1 THEN 1 ELSE 0 END) AS on_time_shipments
    FROM fact_transport_execution fte
    LEFT JOIN dim_date dd
        ON fte.shipment_date = dd.date
    LEFT JOIN dim_location dlo
        ON fte.origin_location_id = dlo.location_id
    LEFT JOIN dim_product dp
        ON fte.product_id = dp.product_id
    GROUP BY dd.year, dd.month, dlo.region, dp.category
),
all_keys AS (
    SELECT year, month, region, product_category FROM inventory_base
    UNION
    SELECT year, month, region, product_category FROM service_base
    UNION
    SELECT year, month, region, product_category FROM supplier_base
    UNION
    SELECT year, month, region, product_category FROM transport_base
),
combined AS (
    SELECT
        k.year,
        k.month,
        k.region,
        k.product_category,
        COALESCE(i.avg_inventory_value, 0) AS avg_inventory_value,
        COALESCE(i.avg_days_of_coverage, 0) AS avg_days_of_coverage,
        COALESCE(i.shortage_risk_sku_count, 0) AS shortage_risk_sku_count,
        COALESCE(i.excess_inventory_sku_count, 0) AS excess_inventory_sku_count,
        COALESCE(i.inventory_record_count, 0) AS inventory_record_count,
        COALESCE(s.total_order_lines, 0) AS total_order_lines,
        COALESCE(s.on_time_order_lines, 0) AS on_time_order_lines,
        COALESCE(s.in_full_order_lines, 0) AS in_full_order_lines,
        COALESCE(s.otif_order_lines, 0) AS otif_order_lines,
        COALESCE(s.late_only_count, 0) AS late_only_count,
        COALESCE(s.qty_short_count, 0) AS qty_short_count,
        COALESCE(s.late_and_short_count, 0) AS late_and_short_count,
        COALESCE(s.not_shipped_count, 0) AS not_shipped_count,
        COALESCE(sp.total_pos, 0) AS total_pos,
        COALESCE(sp.avg_lead_time_deviation, 0) AS avg_lead_time_deviation,
        COALESCE(sp.late_po_count, 0) AS late_po_count,
        COALESCE(t.total_shipments, 0) AS total_shipments,
        COALESCE(t.avg_shipment_cost, 0) AS avg_shipment_cost,
        COALESCE(t.total_shipment_cost, 0) AS total_shipment_cost,
        COALESCE(t.avg_transit_time, 0) AS avg_transit_time,
        COALESCE(t.on_time_shipments, 0) AS on_time_shipments
    FROM all_keys k
    LEFT JOIN inventory_base i
        ON k.year = i.year AND k.month = i.month AND k.region = i.region AND k.product_category = i.product_category
    LEFT JOIN service_base s
        ON k.year = s.year AND k.month = s.month AND k.region = s.region AND k.product_category = s.product_category
    LEFT JOIN supplier_base sp
        ON k.year = sp.year AND k.month = sp.month AND k.region = sp.region AND k.product_category = sp.product_category
    LEFT JOIN transport_base t
        ON k.year = t.year AND k.month = t.month AND k.region = t.region AND k.product_category = t.product_category
),
final_calc AS (
    SELECT
        *,
        CASE WHEN total_order_lines > 0 THEN ROUND(otif_order_lines * 100.0 / total_order_lines, 2) END AS otif_pct,
        CASE WHEN total_order_lines > 0 THEN ROUND(on_time_order_lines * 100.0 / total_order_lines, 2) END AS on_time_pct,
        CASE WHEN total_order_lines > 0 THEN ROUND(in_full_order_lines * 100.0 / total_order_lines, 2) END AS in_full_pct,
        CASE WHEN total_pos > 0 THEN ROUND(late_po_count * 100.0 / total_pos, 2) END AS late_po_pct,
        CASE WHEN total_shipments > 0 THEN ROUND(on_time_shipments * 100.0 / total_shipments, 2) END AS transport_on_time_pct,
        CASE WHEN inventory_record_count > 0 THEN ROUND(shortage_risk_sku_count * 100.0 / inventory_record_count, 2) END AS shortage_risk_pct,
        CASE WHEN inventory_record_count > 0 THEN ROUND(excess_inventory_sku_count * 100.0 / inventory_record_count, 2) END AS excess_inventory_pct
    FROM combined
)
SELECT
    *,
    CASE
        WHEN otif_pct < 90 AND shortage_risk_pct > 15 THEN 'CRITICAL_SERVICE_AND_INVENTORY'
        WHEN otif_pct < 90 AND late_po_pct > 20 THEN 'SUPPLIER_DRIVEN_SERVICE_RISK'
        WHEN otif_pct >= 95 AND avg_shipment_cost > 500 THEN 'SERVICE_PROTECTED_BY_HIGH_FREIGHT_COST'
        WHEN excess_inventory_pct > 20 AND otif_pct < 95 THEN 'HIGH_INVENTORY_LOW_SERVICE_PARADOX'
        ELSE 'STABLE_OR_REVIEW'
    END AS executive_alert
FROM final_calc;
