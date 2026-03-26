-- ============================================================
-- FILE: reconciliation_checks.sql
-- PURPOSE:
-- Reconcile source totals against business-layer totals.
-- ============================================================

-- Ordered quantity reconciliation
SELECT
    'orders_to_fact_order_fulfillment' AS reconciliation_name,
    (SELECT COALESCE(SUM(ordered_qty), 0) FROM stg_orders) AS staging_total,
    (SELECT COALESCE(SUM(ordered_qty), 0) FROM fact_order_fulfillment) AS fact_total,
    (SELECT COALESCE(SUM(ordered_qty), 0) FROM fact_order_fulfillment)
      - (SELECT COALESCE(SUM(ordered_qty), 0) FROM stg_orders) AS variance

UNION ALL

-- Inventory reconciliation
SELECT
    'inventory_to_fact_inventory_position',
    (SELECT COALESCE(SUM(on_hand_qty), 0) FROM stg_inventory),
    (SELECT COALESCE(SUM(on_hand_qty), 0) FROM fact_inventory_position),
    (SELECT COALESCE(SUM(on_hand_qty), 0) FROM fact_inventory_position)
      - (SELECT COALESCE(SUM(on_hand_qty), 0) FROM stg_inventory)

UNION ALL

-- Shipment cost reconciliation
SELECT
    'transport_to_fact_transport_execution',
    (SELECT COALESCE(SUM(shipment_cost), 0) FROM stg_transport),
    (SELECT COALESCE(SUM(shipment_cost), 0) FROM fact_transport_execution),
    (SELECT COALESCE(SUM(shipment_cost), 0) FROM fact_transport_execution)
      - (SELECT COALESCE(SUM(shipment_cost), 0) FROM stg_transport);
