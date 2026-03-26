-- ============================================================
-- FILE: stg_suppliers.sql
-- PURPOSE:
-- Standardize purchase order and receipt execution data.
-- ============================================================

DROP TABLE IF EXISTS stg_suppliers;

CREATE TABLE stg_suppliers AS
WITH cleaned AS (
    SELECT
        TRIM(po_id) AS po_id,
        TRIM(supplier_id) AS supplier_id,
        TRIM(product_id) AS product_id,
        TRIM(location_id) AS location_id,
        CAST(order_date AS DATE) AS order_date,
        CAST(promised_date AS DATE) AS promised_date,
        CAST(actual_receipt_date AS DATE) AS actual_receipt_date,
        COALESCE(ordered_qty, 0) AS ordered_qty,
        COALESCE(received_qty, 0) AS received_qty,
        source_system,
        load_ts,
        ROW_NUMBER() OVER (
            PARTITION BY po_id
            ORDER BY load_ts DESC
        ) AS rn
    FROM raw_suppliers
    WHERE po_id IS NOT NULL
)
SELECT
    po_id,
    supplier_id,
    product_id,
    location_id,
    order_date,
    promised_date,
    actual_receipt_date,
    ordered_qty,
    received_qty,
    source_system,
    load_ts
FROM cleaned
WHERE rn = 1;
