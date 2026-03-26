-- ============================================================
-- FILE: stg_inventory.sql
-- PURPOSE:
-- Standardize daily inventory balances.
-- ============================================================

DROP TABLE IF EXISTS stg_inventory;

CREATE TABLE stg_inventory AS
WITH cleaned AS (
    SELECT
        CAST(inventory_date AS DATE) AS inventory_date,
        TRIM(product_id) AS product_id,
        TRIM(location_id) AS location_id,
        COALESCE(on_hand_qty, 0) AS on_hand_qty,
        COALESCE(blocked_qty, 0) AS blocked_qty,
        source_system,
        load_ts,
        ROW_NUMBER() OVER (
            PARTITION BY inventory_date, product_id, location_id
            ORDER BY load_ts DESC
        ) AS rn
    FROM raw_inventory
    WHERE inventory_date IS NOT NULL
      AND product_id IS NOT NULL
      AND location_id IS NOT NULL
)
SELECT
    inventory_date,
    product_id,
    location_id,
    on_hand_qty,
    blocked_qty,
    source_system,
    load_ts
FROM cleaned
WHERE rn = 1;
