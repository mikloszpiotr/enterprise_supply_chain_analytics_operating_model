-- ============================================================
-- FILE: create_indexes.sql
-- PURPOSE:
-- Add practical indexes for joins and reporting queries.
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_stg_orders_keys
    ON stg_orders (order_id, order_line_id, product_id, customer_id, ship_from_location_id, order_date);

CREATE INDEX IF NOT EXISTS idx_stg_inventory_keys
    ON stg_inventory (inventory_date, product_id, location_id);

CREATE INDEX IF NOT EXISTS idx_stg_shipments_keys
    ON stg_shipments (order_id, order_line_id, shipment_date, delivery_date);

CREATE INDEX IF NOT EXISTS idx_stg_transport_keys
    ON stg_transport (shipment_id, shipment_date, origin_location_id, carrier_id);

CREATE INDEX IF NOT EXISTS idx_stg_suppliers_keys
    ON stg_suppliers (po_id, supplier_id, product_id, location_id, order_date);

CREATE INDEX IF NOT EXISTS idx_stg_forecast_keys
    ON stg_forecast (forecast_date, product_id, location_id);

CREATE INDEX IF NOT EXISTS idx_fact_inventory_position_keys
    ON fact_inventory_position (snapshot_date, product_id, location_id);

CREATE INDEX IF NOT EXISTS idx_fact_order_fulfillment_keys
    ON fact_order_fulfillment (order_date, customer_id, product_id, location_id);

CREATE INDEX IF NOT EXISTS idx_fact_transport_execution_keys
    ON fact_transport_execution (shipment_date, product_id, origin_location_id, destination_location_id);

CREATE INDEX IF NOT EXISTS idx_fact_procurement_reliability_keys
    ON fact_procurement_reliability (order_date, supplier_id, product_id, location_id);

CREATE INDEX IF NOT EXISTS idx_fact_demand_signal_keys
    ON fact_demand_signal (demand_date, product_id, location_id);
