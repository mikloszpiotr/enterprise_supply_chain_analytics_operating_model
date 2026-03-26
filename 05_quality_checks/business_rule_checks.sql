-- ============================================================
-- FILE: business_rule_checks.sql
-- PURPOSE:
-- Validate core business logic assumptions.
-- ============================================================

-- Negative quantities that should not exist
SELECT 'negative_order_qty' AS rule_name, COUNT(*) AS issue_count
FROM stg_orders
WHERE ordered_qty < 0

UNION ALL
SELECT 'negative_inventory_qty', COUNT(*)
FROM stg_inventory
WHERE on_hand_qty < 0 OR blocked_qty < 0

UNION ALL
SELECT 'negative_forecast_qty', COUNT(*)
FROM stg_forecast
WHERE forecast_qty < 0

UNION ALL
SELECT 'delivery_before_order_date', COUNT(*)
FROM fact_order_fulfillment
WHERE final_delivery_date IS NOT NULL
  AND order_date IS NOT NULL
  AND final_delivery_date < order_date

UNION ALL
SELECT 'actual_receipt_before_order_date', COUNT(*)
FROM fact_procurement_reliability
WHERE actual_receipt_date IS NOT NULL
  AND order_date IS NOT NULL
  AND actual_receipt_date < order_date

UNION ALL
SELECT 'otif_flag_without_on_time_and_in_full', COUNT(*)
FROM fact_order_fulfillment
WHERE otif_flag = 1
  AND (on_time_flag <> 1 OR in_full_flag <> 1);
