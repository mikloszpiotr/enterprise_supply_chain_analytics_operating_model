-- ============================================================
-- FACT TABLE: fact_transport_execution
-- PURPOSE:
-- Build shipment-level transport performance and cost fact.
-- ============================================================

DROP TABLE IF EXISTS fact_transport_execution;

CREATE TABLE fact_transport_execution AS
SELECT
    shipment_id,
    product_id,
    shipment_date,
    origin_location_id,
    destination_location_id,
    carrier_id,
    transport_mode,
    shipment_cost,
    units_shipped,
    CASE
        WHEN units_shipped > 0
            THEN ROUND(shipment_cost * 1.0 / units_shipped, 4)
        ELSE NULL
    END AS cost_per_unit_shipped,
    transit_time_days AS transit_time,
    on_time_flag,
    premium_freight_flag
FROM stg_transport;
