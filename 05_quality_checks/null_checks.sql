-- ============================================================
-- FILE: null_checks.sql
-- PURPOSE:
-- Detect critical missing values in staging and fact tables.
-- ============================================================

-- Staging null checks
SELECT 'stg_orders' AS table_name, COUNT(*) AS null_key_count
FROM stg_orders
WHERE order_id IS NULL OR order_line_id IS NULL OR product_id IS NULL OR ship_from_location_id IS NULL

UNION ALL
SELECT 'stg_inventory', COUNT(*)
FROM stg_inventory
WHERE inventory_date IS NULL OR product_id IS NULL OR location_id IS NULL

UNION ALL
SELECT 'stg_shipments', COUNT(*)
FROM stg_shipments
WHERE shipment_id IS NULL OR order_id IS NULL OR order_line_id IS NULL

UNION ALL
SELECT 'stg_suppliers', COUNT(*)
FROM stg_suppliers
WHERE po_id IS NULL OR supplier_id IS NULL OR product_id IS NULL OR location_id IS NULL

UNION ALL
SELECT 'fact_inventory_position', COUNT(*)
FROM fact_inventory_position
WHERE snapshot_date IS NULL OR product_id IS NULL OR location_id IS NULL

UNION ALL
SELECT 'fact_order_fulfillment', COUNT(*)
FROM fact_order_fulfillment
WHERE order_id IS NULL OR order_line_id IS NULL OR product_id IS NULL;
