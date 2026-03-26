-- ============================================================
-- FACT TABLE: fact_inventory_position
-- PURPOSE:
-- Build a daily SKU-location inventory fact table that combines
-- stock on hand, inbound supply, demand forecast, and inventory
-- coverage metrics.
-- ============================================================

DROP TABLE IF EXISTS fact_inventory_position;

CREATE TABLE fact_inventory_position AS
WITH base_inventory AS (
    SELECT
        inventory_date AS snapshot_date,
        product_id,
        location_id,
        SUM(on_hand_qty) AS on_hand_qty,
        SUM(blocked_qty) AS blocked_qty
    FROM stg_inventory
    GROUP BY inventory_date, product_id, location_id
),
inbound_supply AS (
    SELECT
        expected_receipt_date AS snapshot_date,
        product_id,
        location_id,
        SUM(open_qty) AS inbound_qty
    FROM stg_inbound_orders
    WHERE order_status IN ('OPEN', 'IN_TRANSIT', 'PARTIALLY_RECEIVED')
    GROUP BY expected_receipt_date, product_id, location_id
),
forecast_demand AS (
    SELECT
        forecast_date AS snapshot_date,
        product_id,
        location_id,
        SUM(forecast_qty) AS forecast_qty
    FROM stg_forecast
    GROUP BY forecast_date, product_id, location_id
),
product_cost AS (
    SELECT
        product_id,
        standard_cost
    FROM dim_product
),
combined AS (
    SELECT
        COALESCE(i.snapshot_date, s.snapshot_date, f.snapshot_date) AS snapshot_date,
        COALESCE(i.product_id, s.product_id, f.product_id) AS product_id,
        COALESCE(i.location_id, s.location_id, f.location_id) AS location_id,
        COALESCE(i.on_hand_qty, 0) AS on_hand_qty,
        COALESCE(i.blocked_qty, 0) AS blocked_qty,
        COALESCE(s.inbound_qty, 0) AS inbound_qty,
        COALESCE(f.forecast_qty, 0) AS forecast_qty
    FROM base_inventory i
    FULL OUTER JOIN inbound_supply s
        ON i.snapshot_date = s.snapshot_date
       AND i.product_id = s.product_id
       AND i.location_id = s.location_id
    FULL OUTER JOIN forecast_demand f
        ON COALESCE(i.snapshot_date, s.snapshot_date) = f.snapshot_date
       AND COALESCE(i.product_id, s.product_id) = f.product_id
       AND COALESCE(i.location_id, s.location_id) = f.location_id
),
final_calc AS (
    SELECT
        c.snapshot_date,
        c.product_id,
        c.location_id,
        c.on_hand_qty,
        c.blocked_qty,
        c.inbound_qty,
        c.forecast_qty,
        (c.on_hand_qty - c.blocked_qty + c.inbound_qty) AS available_inventory_qty,
        (c.on_hand_qty - c.blocked_qty + c.inbound_qty - c.forecast_qty) AS net_inventory_after_forecast,
        CASE
            WHEN c.forecast_qty > 0
                THEN ROUND((c.on_hand_qty - c.blocked_qty + c.inbound_qty) * 1.0 / c.forecast_qty, 2)
            ELSE NULL
        END AS days_of_coverage,
        CASE
            WHEN (c.on_hand_qty - c.blocked_qty + c.inbound_qty - c.forecast_qty) < 0 THEN 1
            ELSE 0
        END AS shortage_risk_flag,
        CASE
            WHEN c.forecast_qty = 0
                 AND (c.on_hand_qty - c.blocked_qty + c.inbound_qty) > 0 THEN 1
            WHEN c.forecast_qty > 0
                 AND ((c.on_hand_qty - c.blocked_qty + c.inbound_qty) * 1.0 / c.forecast_qty) > 30 THEN 1
            ELSE 0
        END AS excess_inventory_flag
    FROM combined c
)
SELECT
    f.snapshot_date,
    f.product_id,
    p.standard_cost,
    f.location_id,
    f.on_hand_qty,
    f.blocked_qty,
    f.inbound_qty,
    f.forecast_qty,
    f.available_inventory_qty,
    f.net_inventory_after_forecast,
    f.days_of_coverage,
    f.shortage_risk_flag,
    f.excess_inventory_flag,
    ROUND(f.available_inventory_qty * COALESCE(p.standard_cost, 0), 2) AS inventory_value
FROM final_calc f
LEFT JOIN product_cost p
    ON f.product_id = p.product_id;
