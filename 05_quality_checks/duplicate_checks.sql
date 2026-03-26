-- ============================================================
-- FILE: duplicate_checks.sql
-- PURPOSE:
-- Detect duplicate business keys after staging/modeling.
-- ============================================================

SELECT 'stg_orders' AS table_name, COUNT(*) AS duplicate_groups
FROM (
    SELECT order_id, order_line_id, COUNT(*) AS cnt
    FROM stg_orders
    GROUP BY order_id, order_line_id
    HAVING COUNT(*) > 1
) x

UNION ALL
SELECT 'stg_inventory', COUNT(*)
FROM (
    SELECT inventory_date, product_id, location_id, COUNT(*) AS cnt
    FROM stg_inventory
    GROUP BY inventory_date, product_id, location_id
    HAVING COUNT(*) > 1
) x

UNION ALL
SELECT 'fact_inventory_position', COUNT(*)
FROM (
    SELECT snapshot_date, product_id, location_id, COUNT(*) AS cnt
    FROM fact_inventory_position
    GROUP BY snapshot_date, product_id, location_id
    HAVING COUNT(*) > 1
) x

UNION ALL
SELECT 'fact_order_fulfillment', COUNT(*)
FROM (
    SELECT order_id, order_line_id, COUNT(*) AS cnt
    FROM fact_order_fulfillment
    GROUP BY order_id, order_line_id
    HAVING COUNT(*) > 1
) x;
