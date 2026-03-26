-- ============================================================
-- FACT TABLE: fact_order_fulfillment
-- PURPOSE:
-- Build an order-line level service execution fact table.
-- ============================================================

DROP TABLE IF EXISTS fact_order_fulfillment;

CREATE TABLE fact_order_fulfillment AS
WITH orders AS (
    SELECT
        order_id,
        order_line_id,
        customer_id,
        product_id,
        ship_from_location_id AS location_id,
        order_date,
        requested_delivery_date,
        ordered_qty
    FROM stg_orders
),
shipments AS (
    SELECT
        order_id,
        order_line_id,
        MIN(shipment_date) AS first_shipment_date,
        MAX(delivery_date) AS final_delivery_date,
        SUM(shipped_qty) AS shipped_qty,
        SUM(delivered_qty) AS delivered_qty
    FROM stg_shipments
    GROUP BY order_id, order_line_id
),
returns_data AS (
    SELECT
        order_id,
        order_line_id,
        SUM(return_qty) AS return_qty
    FROM stg_returns
    GROUP BY order_id, order_line_id
),
combined AS (
    SELECT
        o.order_id,
        o.order_line_id,
        o.customer_id,
        o.product_id,
        o.location_id,
        o.order_date,
        o.requested_delivery_date,
        s.first_shipment_date,
        s.final_delivery_date,
        o.ordered_qty,
        COALESCE(s.shipped_qty, 0) AS shipped_qty,
        COALESCE(s.delivered_qty, 0) AS delivered_qty,
        COALESCE(r.return_qty, 0) AS return_qty
    FROM orders o
    LEFT JOIN shipments s
        ON o.order_id = s.order_id
       AND o.order_line_id = s.order_line_id
    LEFT JOIN returns_data r
        ON o.order_id = r.order_id
       AND o.order_line_id = r.order_line_id
),
final_calc AS (
    SELECT
        order_id,
        order_line_id,
        customer_id,
        product_id,
        location_id,
        order_date,
        requested_delivery_date,
        first_shipment_date,
        final_delivery_date,
        ordered_qty,
        shipped_qty,
        delivered_qty,
        return_qty,
        (delivered_qty - return_qty) AS net_delivered_qty,
        CASE
            WHEN (delivered_qty - return_qty) >= ordered_qty THEN 1
            ELSE 0
        END AS in_full_flag,
        CASE
            WHEN final_delivery_date IS NOT NULL
             AND final_delivery_date <= requested_delivery_date THEN 1
            ELSE 0
        END AS on_time_flag,
        CASE
            WHEN (delivered_qty - return_qty) >= ordered_qty
             AND final_delivery_date IS NOT NULL
             AND final_delivery_date <= requested_delivery_date THEN 1
            ELSE 0
        END AS otif_flag,
        CASE
            WHEN shipped_qty = 0 THEN 'NOT_SHIPPED'
            WHEN (delivered_qty - return_qty) < ordered_qty
                 AND final_delivery_date IS NOT NULL
                 AND final_delivery_date <= requested_delivery_date THEN 'QTY_SHORT'
            WHEN (delivered_qty - return_qty) >= ordered_qty
                 AND final_delivery_date > requested_delivery_date THEN 'LATE'
            WHEN (delivered_qty - return_qty) < ordered_qty
                 AND final_delivery_date > requested_delivery_date THEN 'LATE_AND_SHORT'
            WHEN final_delivery_date IS NULL THEN 'IN_TRANSIT_OR_MISSING_POD'
            ELSE 'SUCCESS'
        END AS service_failure_reason,
        CASE
            WHEN final_delivery_date IS NOT NULL
                THEN (final_delivery_date - requested_delivery_date)
            ELSE NULL
        END AS delivery_days_vs_request
    FROM combined
)
SELECT *
FROM final_calc;
