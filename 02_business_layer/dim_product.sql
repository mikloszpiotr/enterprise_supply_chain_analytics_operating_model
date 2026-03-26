-- ============================================================
-- FILE: dim_product.sql
-- PURPOSE:
-- Build product dimension from product master.
-- ============================================================

DROP TABLE IF EXISTS dim_product;

CREATE TABLE dim_product AS
WITH cleaned AS (
    SELECT
        TRIM(product_id) AS product_id,
        TRIM(product_name) AS product_name,
        TRIM(category) AS category,
        TRIM(brand) AS brand,
        COALESCE(standard_cost, 0) AS standard_cost,
        COALESCE(active_flag, 1) AS active_flag,
        ROW_NUMBER() OVER (
            PARTITION BY product_id
            ORDER BY load_ts DESC
        ) AS rn
    FROM raw_product_master
    WHERE product_id IS NOT NULL
)
SELECT
    product_id,
    product_name,
    category,
    brand,
    standard_cost,
    active_flag
FROM cleaned
WHERE rn = 1;
