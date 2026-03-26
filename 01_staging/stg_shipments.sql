-- ============================================================
-- FILE: stg_shipments.sql
-- PURPOSE:
-- Standardize shipment execution records.
-- ============================================================

DROP TABLE IF EXISTS stg_shipments;

CREATE TABLE stg_shipments AS
WITH cleaned AS (
    SELECT
        TRIM(shipment_id) AS shipment_id,
        TRIM(order_id) AS order_id,
        TRIM(order_line_id) AS order_line_id,
        TRIM(product_id) AS product_id,
        CAST(shipment_date AS DATE) AS shipment_date,
        CAST(delivery_date AS DATE) AS delivery_date,
        COALESCE(shipped_qty, 0) AS shipped_qty,
        COALESCE(delivered_qty, 0) AS delivered_qty,
        TRIM(origin_location_id) AS origin_location_id,
        TRIM(destination_location_id) AS destination_location_id,
        TRIM(carrier_id) AS carrier_id,
        source_system,
        load_ts,
        ROW_NUMBER() OVER (
            PARTITION BY shipment_id
            ORDER BY load_ts DESC
        ) AS rn
    FROM raw_shipments
    WHERE shipment_id IS NOT NULL
)
SELECT
    shipment_id,
    order_id,
    order_line_id,
    product_id,
    shipment_date,
    delivery_date,
    shipped_qty,
    delivered_qty,
    origin_location_id,
    destination_location_id,
    carrier_id,
    source_system,
    load_ts
FROM cleaned
WHERE rn = 1;
