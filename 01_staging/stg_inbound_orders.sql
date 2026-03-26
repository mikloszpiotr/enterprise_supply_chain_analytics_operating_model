-- ============================================================
-- FILE: stg_inbound_orders.sql
-- PURPOSE:
-- Standardize open inbound supply orders.
-- ============================================================

DROP TABLE IF EXISTS stg_inbound_orders;

CREATE TABLE stg_inbound_orders AS
WITH cleaned AS (
    SELECT
        TRIM(inbound_order_id) AS inbound_order_id,
        TRIM(product_id) AS product_id,
        TRIM(location_id) AS location_id,
        CAST(expected_receipt_date AS DATE) AS expected_receipt_date,
        COALESCE(open_qty, 0) AS open_qty,
        UPPER(TRIM(order_status)) AS order_status,
        source_system,
        load_ts,
        ROW_NUMBER() OVER (
            PARTITION BY inbound_order_id
            ORDER BY load_ts DESC
        ) AS rn
    FROM raw_inbound_orders
    WHERE inbound_order_id IS NOT NULL
)
SELECT
    inbound_order_id,
    product_id,
    location_id,
    expected_receipt_date,
    open_qty,
    order_status,
    source_system,
    load_ts
FROM cleaned
WHERE rn = 1;
