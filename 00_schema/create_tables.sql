-- ============================================================
-- FILE: create_tables.sql
-- PURPOSE:
-- Create core raw, staging, dimension, fact, and mart tables.
-- NOTE:
-- This file defines target structures. Ingestion/loading can be
-- handled separately through CSV import, ELT, or dbt pipelines.
-- ============================================================

CREATE SCHEMA IF NOT EXISTS supply_chain_analytics;
SET search_path TO supply_chain_analytics;

-- --------------------------
-- Raw landing tables
-- --------------------------
CREATE TABLE IF NOT EXISTS raw_orders (
    order_id                 VARCHAR(50),
    order_line_id            VARCHAR(50),
    customer_id              VARCHAR(50),
    product_id               VARCHAR(50),
    ship_from_location_id    VARCHAR(50),
    order_date               DATE,
    requested_delivery_date  DATE,
    ordered_qty              NUMERIC(18,2),
    source_system            VARCHAR(50),
    load_ts                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_inventory (
    inventory_date           DATE,
    product_id               VARCHAR(50),
    location_id              VARCHAR(50),
    on_hand_qty              NUMERIC(18,2),
    blocked_qty              NUMERIC(18,2),
    source_system            VARCHAR(50),
    load_ts                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_shipments (
    shipment_id              VARCHAR(50),
    order_id                 VARCHAR(50),
    order_line_id            VARCHAR(50),
    product_id               VARCHAR(50),
    shipment_date            DATE,
    delivery_date            DATE,
    shipped_qty              NUMERIC(18,2),
    delivered_qty            NUMERIC(18,2),
    origin_location_id       VARCHAR(50),
    destination_location_id  VARCHAR(50),
    carrier_id               VARCHAR(50),
    source_system            VARCHAR(50),
    load_ts                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_transport (
    shipment_id              VARCHAR(50),
    product_id               VARCHAR(50),
    shipment_date            DATE,
    origin_location_id       VARCHAR(50),
    destination_location_id  VARCHAR(50),
    carrier_id               VARCHAR(50),
    transport_mode           VARCHAR(50),
    shipment_cost            NUMERIC(18,2),
    units_shipped            NUMERIC(18,2),
    transit_time_days        NUMERIC(18,2),
    on_time_flag             INTEGER,
    premium_freight_flag     INTEGER,
    source_system            VARCHAR(50),
    load_ts                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_suppliers (
    po_id                    VARCHAR(50),
    supplier_id              VARCHAR(50),
    product_id               VARCHAR(50),
    location_id              VARCHAR(50),
    order_date               DATE,
    promised_date            DATE,
    actual_receipt_date      DATE,
    ordered_qty              NUMERIC(18,2),
    received_qty             NUMERIC(18,2),
    source_system            VARCHAR(50),
    load_ts                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_forecast (
    forecast_date            DATE,
    product_id               VARCHAR(50),
    location_id              VARCHAR(50),
    forecast_qty             NUMERIC(18,2),
    source_system            VARCHAR(50),
    load_ts                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_inbound_orders (
    inbound_order_id         VARCHAR(50),
    product_id               VARCHAR(50),
    location_id              VARCHAR(50),
    expected_receipt_date    DATE,
    open_qty                 NUMERIC(18,2),
    order_status             VARCHAR(50),
    source_system            VARCHAR(50),
    load_ts                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_returns (
    return_id                VARCHAR(50),
    order_id                 VARCHAR(50),
    order_line_id            VARCHAR(50),
    return_date              DATE,
    return_qty               NUMERIC(18,2),
    source_system            VARCHAR(50),
    load_ts                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- --------------------------
-- Master data
-- --------------------------
CREATE TABLE IF NOT EXISTS raw_product_master (
    product_id               VARCHAR(50),
    product_name             VARCHAR(255),
    category                 VARCHAR(100),
    brand                    VARCHAR(100),
    standard_cost            NUMERIC(18,2),
    active_flag              INTEGER,
    load_ts                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_location_master (
    location_id              VARCHAR(50),
    location_name            VARCHAR(255),
    location_type            VARCHAR(50),
    region                   VARCHAR(100),
    country                  VARCHAR(100),
    active_flag              INTEGER,
    load_ts                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_supplier_master (
    supplier_id              VARCHAR(50),
    supplier_name            VARCHAR(255),
    country                  VARCHAR(100),
    active_flag              INTEGER,
    load_ts                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_customer_master (
    customer_id              VARCHAR(50),
    customer_name            VARCHAR(255),
    segment                  VARCHAR(100),
    region                   VARCHAR(100),
    country                  VARCHAR(100),
    active_flag              INTEGER,
    load_ts                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_carrier_master (
    carrier_id               VARCHAR(50),
    carrier_name             VARCHAR(255),
    transport_mode           VARCHAR(50),
    active_flag              INTEGER,
    load_ts                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- --------------------------
-- Staging tables
-- --------------------------
CREATE TABLE IF NOT EXISTS stg_orders AS SELECT * FROM raw_orders WHERE 1=0;
CREATE TABLE IF NOT EXISTS stg_inventory AS SELECT * FROM raw_inventory WHERE 1=0;
CREATE TABLE IF NOT EXISTS stg_shipments AS SELECT * FROM raw_shipments WHERE 1=0;
CREATE TABLE IF NOT EXISTS stg_transport AS SELECT * FROM raw_transport WHERE 1=0;
CREATE TABLE IF NOT EXISTS stg_suppliers AS SELECT * FROM raw_suppliers WHERE 1=0;
CREATE TABLE IF NOT EXISTS stg_forecast AS SELECT * FROM raw_forecast WHERE 1=0;
CREATE TABLE IF NOT EXISTS stg_inbound_orders AS SELECT * FROM raw_inbound_orders WHERE 1=0;
CREATE TABLE IF NOT EXISTS stg_returns AS SELECT * FROM raw_returns WHERE 1=0;

-- --------------------------
-- Dimensions
-- --------------------------
CREATE TABLE IF NOT EXISTS dim_product (
    product_id               VARCHAR(50) PRIMARY KEY,
    product_name             VARCHAR(255),
    category                 VARCHAR(100),
    brand                    VARCHAR(100),
    standard_cost            NUMERIC(18,2),
    active_flag              INTEGER
);

CREATE TABLE IF NOT EXISTS dim_location (
    location_id              VARCHAR(50) PRIMARY KEY,
    location_name            VARCHAR(255),
    location_type            VARCHAR(50),
    region                   VARCHAR(100),
    country                  VARCHAR(100),
    active_flag              INTEGER
);

CREATE TABLE IF NOT EXISTS dim_supplier (
    supplier_id              VARCHAR(50) PRIMARY KEY,
    supplier_name            VARCHAR(255),
    country                  VARCHAR(100),
    active_flag              INTEGER
);

CREATE TABLE IF NOT EXISTS dim_customer (
    customer_id              VARCHAR(50) PRIMARY KEY,
    customer_name            VARCHAR(255),
    segment                  VARCHAR(100),
    region                   VARCHAR(100),
    country                  VARCHAR(100),
    active_flag              INTEGER
);

CREATE TABLE IF NOT EXISTS dim_carrier (
    carrier_id               VARCHAR(50) PRIMARY KEY,
    carrier_name             VARCHAR(255),
    transport_mode           VARCHAR(50),
    active_flag              INTEGER
);

CREATE TABLE IF NOT EXISTS dim_date (
    date                     DATE PRIMARY KEY,
    day_of_month             INTEGER,
    week                     INTEGER,
    month                    INTEGER,
    quarter                  INTEGER,
    year                     INTEGER,
    month_name               VARCHAR(20),
    weekday_name             VARCHAR(20)
);

-- --------------------------
-- Facts
-- --------------------------
CREATE TABLE IF NOT EXISTS fact_inventory_position (
    snapshot_date            DATE,
    product_id               VARCHAR(50),
    standard_cost            NUMERIC(18,2),
    location_id              VARCHAR(50),
    on_hand_qty              NUMERIC(18,2),
    blocked_qty              NUMERIC(18,2),
    inbound_qty              NUMERIC(18,2),
    forecast_qty             NUMERIC(18,2),
    available_inventory_qty  NUMERIC(18,2),
    net_inventory_after_forecast NUMERIC(18,2),
    days_of_coverage         NUMERIC(18,2),
    shortage_risk_flag       INTEGER,
    excess_inventory_flag    INTEGER,
    inventory_value          NUMERIC(18,2)
);

CREATE TABLE IF NOT EXISTS fact_order_fulfillment (
    order_id                 VARCHAR(50),
    order_line_id            VARCHAR(50),
    customer_id              VARCHAR(50),
    product_id               VARCHAR(50),
    location_id              VARCHAR(50),
    order_date               DATE,
    requested_delivery_date  DATE,
    first_shipment_date      DATE,
    final_delivery_date      DATE,
    ordered_qty              NUMERIC(18,2),
    shipped_qty              NUMERIC(18,2),
    delivered_qty            NUMERIC(18,2),
    return_qty               NUMERIC(18,2),
    net_delivered_qty        NUMERIC(18,2),
    in_full_flag             INTEGER,
    on_time_flag             INTEGER,
    otif_flag                INTEGER,
    service_failure_reason   VARCHAR(50),
    delivery_days_vs_request INTEGER
);

CREATE TABLE IF NOT EXISTS fact_transport_execution (
    shipment_id              VARCHAR(50),
    product_id               VARCHAR(50),
    shipment_date            DATE,
    origin_location_id       VARCHAR(50),
    destination_location_id  VARCHAR(50),
    carrier_id               VARCHAR(50),
    transport_mode           VARCHAR(50),
    shipment_cost            NUMERIC(18,2),
    units_shipped            NUMERIC(18,2),
    cost_per_unit_shipped    NUMERIC(18,4),
    transit_time             NUMERIC(18,2),
    on_time_flag             INTEGER,
    premium_freight_flag     INTEGER
);

CREATE TABLE IF NOT EXISTS fact_procurement_reliability (
    po_id                    VARCHAR(50),
    supplier_id              VARCHAR(50),
    product_id               VARCHAR(50),
    location_id              VARCHAR(50),
    order_date               DATE,
    promised_date            DATE,
    actual_receipt_date      DATE,
    ordered_qty              NUMERIC(18,2),
    received_qty             NUMERIC(18,2),
    planned_lead_time_days   INTEGER,
    actual_lead_time_days    INTEGER,
    lead_time_deviation      INTEGER,
    in_full_receipt_flag     INTEGER,
    late_po_flag             INTEGER
);

CREATE TABLE IF NOT EXISTS fact_demand_signal (
    demand_date              DATE,
    product_id               VARCHAR(50),
    location_id              VARCHAR(50),
    forecast_qty             NUMERIC(18,2),
    actual_demand_qty        NUMERIC(18,2),
    forecast_error_qty       NUMERIC(18,2),
    absolute_error_qty       NUMERIC(18,2),
    bias_flag                INTEGER
);

-- --------------------------
-- KPI tables/views
-- --------------------------
CREATE TABLE IF NOT EXISTS kpi_service_level (
    year                     INTEGER,
    month                    INTEGER,
    region                   VARCHAR(100),
    product_category         VARCHAR(100),
    total_order_lines        INTEGER,
    otif_pct                 NUMERIC(18,2),
    on_time_pct              NUMERIC(18,2),
    in_full_pct              NUMERIC(18,2)
);

CREATE TABLE IF NOT EXISTS kpi_inventory_turns (
    year                     INTEGER,
    month                    INTEGER,
    region                   VARCHAR(100),
    product_category         VARCHAR(100),
    avg_inventory_value      NUMERIC(18,2),
    estimated_cogs           NUMERIC(18,2),
    inventory_turns          NUMERIC(18,2)
);

CREATE TABLE IF NOT EXISTS kpi_stockout_risk (
    year                     INTEGER,
    month                    INTEGER,
    region                   VARCHAR(100),
    product_category         VARCHAR(100),
    inventory_record_count   INTEGER,
    shortage_risk_sku_count  INTEGER,
    shortage_risk_pct        NUMERIC(18,2)
);

CREATE TABLE IF NOT EXISTS kpi_otif (
    year                     INTEGER,
    month                    INTEGER,
    region                   VARCHAR(100),
    customer_segment         VARCHAR(100),
    product_category         VARCHAR(100),
    total_order_lines        INTEGER,
    otif_order_lines         INTEGER,
    otif_pct                 NUMERIC(18,2)
);

CREATE TABLE IF NOT EXISTS kpi_lead_time_variability (
    year                     INTEGER,
    month                    INTEGER,
    region                   VARCHAR(100),
    product_category         VARCHAR(100),
    supplier_count           INTEGER,
    total_pos                INTEGER,
    avg_lead_time_deviation  NUMERIC(18,2),
    late_po_pct              NUMERIC(18,2)
);

CREATE TABLE IF NOT EXISTS kpi_forecast_bias (
    year                     INTEGER,
    month                    INTEGER,
    region                   VARCHAR(100),
    product_category         VARCHAR(100),
    total_forecast_qty       NUMERIC(18,2),
    total_actual_demand_qty  NUMERIC(18,2),
    total_forecast_error_qty NUMERIC(18,2),
    forecast_bias_pct        NUMERIC(18,2)
);

CREATE TABLE IF NOT EXISTS kpi_transport_cost_per_unit (
    year                     INTEGER,
    month                    INTEGER,
    region                   VARCHAR(100),
    product_category         VARCHAR(100),
    total_shipment_cost      NUMERIC(18,2),
    total_units_shipped      NUMERIC(18,2),
    transport_cost_per_unit  NUMERIC(18,4)
);

-- --------------------------
-- Decision marts
-- --------------------------
CREATE TABLE IF NOT EXISTS mart_inventory_decision (
    year                     INTEGER,
    month                    INTEGER,
    region                   VARCHAR(100),
    product_category         VARCHAR(100),
    avg_inventory_value      NUMERIC(18,2),
    avg_days_of_coverage     NUMERIC(18,2),
    shortage_risk_pct        NUMERIC(18,2),
    excess_inventory_pct     NUMERIC(18,2),
    inventory_decision_flag  VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS mart_replenishment_decision (
    year                     INTEGER,
    month                    INTEGER,
    region                   VARCHAR(100),
    product_category         VARCHAR(100),
    shortage_risk_pct        NUMERIC(18,2),
    avg_days_of_coverage     NUMERIC(18,2),
    otif_pct                 NUMERIC(18,2),
    replenishment_priority   VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS mart_supplier_risk (
    year                     INTEGER,
    month                    INTEGER,
    region                   VARCHAR(100),
    product_category         VARCHAR(100),
    total_pos                INTEGER,
    avg_lead_time_deviation  NUMERIC(18,2),
    late_po_pct              NUMERIC(18,2),
    supplier_risk_flag       VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS mart_transport_tradeoff (
    year                     INTEGER,
    month                    INTEGER,
    region                   VARCHAR(100),
    product_category         VARCHAR(100),
    total_shipment_cost      NUMERIC(18,2),
    transport_cost_per_unit  NUMERIC(18,4),
    transport_on_time_pct    NUMERIC(18,2),
    premium_freight_share_pct NUMERIC(18,2),
    transport_tradeoff_flag  VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS mart_executive_control_tower (
    year                     INTEGER,
    month                    INTEGER,
    region                   VARCHAR(100),
    product_category         VARCHAR(100),
    avg_inventory_value      NUMERIC(18,2),
    avg_days_of_coverage     NUMERIC(18,2),
    shortage_risk_sku_count  INTEGER,
    excess_inventory_sku_count INTEGER,
    inventory_record_count   INTEGER,
    total_order_lines        INTEGER,
    on_time_order_lines      INTEGER,
    in_full_order_lines      INTEGER,
    otif_order_lines         INTEGER,
    late_only_count          INTEGER,
    qty_short_count          INTEGER,
    late_and_short_count     INTEGER,
    not_shipped_count        INTEGER,
    total_pos                INTEGER,
    avg_lead_time_deviation  NUMERIC(18,2),
    late_po_count            INTEGER,
    total_shipments          INTEGER,
    avg_shipment_cost        NUMERIC(18,2),
    total_shipment_cost      NUMERIC(18,2),
    avg_transit_time         NUMERIC(18,2),
    on_time_shipments        INTEGER,
    otif_pct                 NUMERIC(18,2),
    on_time_pct              NUMERIC(18,2),
    in_full_pct              NUMERIC(18,2),
    late_po_pct              NUMERIC(18,2),
    transport_on_time_pct    NUMERIC(18,2),
    shortage_risk_pct        NUMERIC(18,2),
    excess_inventory_pct     NUMERIC(18,2),
    executive_alert          VARCHAR(100)
);
