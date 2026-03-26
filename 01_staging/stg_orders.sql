-- ============================================================
-- FILE: stg_orders.sql
-- PURPOSE:
-- Standardize customer order data from raw_orders.
-- ============================================================

DROP TABLE IF EXISTS stg_orders;

CREATE TABLE stg_orders AS
WITH cleaned AS (
    SELECT
        TRIM(order_id) AS order_id,
        TRIM(order_line_id) AS order_line_id,
        TRIM(customer_id) AS customer_id,
        TRIM(product_id) AS product_id,
        TRIM(ship_from_location_id) AS ship_from_location_id,
        CAST(order_date AS DATE) AS order_date,
        CAST(requested_delivery_date AS DATE) AS requested_delivery_date,
        COALESCE(ordered_qty, 0) AS ordered_qty,
        source_system,
        load_ts,
        ROW_NUMBER() OVER (
            PARTITION BY order_id, order_line_id
            ORDER BY load_ts DESC
        ) AS rn
    FROM raw_orders
    WHERE order_id IS NOT NULL
      AND order_line_id IS NOT NULL
      AND product_id IS NOT NULL
)
SELECT
    order_id,
    order_line_id,
    customer_id,
    product_id,
    ship_from_location_id,
    order_date,
    requested_delivery_date,
    ordered_qty,
    source_system,
    load_ts
FROM cleaned
WHERE rn = 1;
