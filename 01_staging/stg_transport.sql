-- ============================================================
-- FILE: stg_transport.sql
-- PURPOSE:
-- Standardize transport cost and carrier execution data.
-- ============================================================

DROP TABLE IF EXISTS stg_transport;

CREATE TABLE stg_transport AS
WITH cleaned AS (
    SELECT
        TRIM(shipment_id) AS shipment_id,
        TRIM(product_id) AS product_id,
        CAST(shipment_date AS DATE) AS shipment_date,
        TRIM(origin_location_id) AS origin_location_id,
        TRIM(destination_location_id) AS destination_location_id,
        TRIM(carrier_id) AS carrier_id,
        UPPER(TRIM(transport_mode)) AS transport_mode,
        COALESCE(shipment_cost, 0) AS shipment_cost,
        COALESCE(units_shipped, 0) AS units_shipped,
        COALESCE(transit_time_days, 0) AS transit_time_days,
        COALESCE(on_time_flag, 0) AS on_time_flag,
        COALESCE(premium_freight_flag, 0) AS premium_freight_flag,
        source_system,
        load_ts,
        ROW_NUMBER() OVER (
            PARTITION BY shipment_id
            ORDER BY load_ts DESC
        ) AS rn
    FROM raw_transport
    WHERE shipment_id IS NOT NULL
)
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
    transit_time_days,
    on_time_flag,
    premium_freight_flag,
    source_system,
    load_ts
FROM cleaned
WHERE rn = 1;
