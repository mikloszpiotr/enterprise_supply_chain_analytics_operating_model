-- ============================================================
-- FILE: dim_date.sql
-- PURPOSE:
-- Build date dimension from available transaction dates.
-- NOTE:
-- Uses PostgreSQL generate_series. Adapt as needed for other DBs.
-- ============================================================

DROP TABLE IF EXISTS dim_date;

CREATE TABLE dim_date AS
WITH bounds AS (
    SELECT
        MIN(min_date) AS start_date,
        MAX(max_date) AS end_date
    FROM (
        SELECT MIN(order_date) AS min_date, MAX(order_date) AS max_date FROM stg_orders
        UNION ALL
        SELECT MIN(inventory_date), MAX(inventory_date) FROM stg_inventory
        UNION ALL
        SELECT MIN(shipment_date), MAX(shipment_date) FROM stg_shipments
        UNION ALL
        SELECT MIN(forecast_date), MAX(forecast_date) FROM stg_forecast
        UNION ALL
        SELECT MIN(order_date), MAX(order_date) FROM stg_suppliers
    ) x
),
calendar AS (
    SELECT generate_series(start_date, end_date, interval '1 day')::date AS date
    FROM bounds
)
SELECT
    date,
    EXTRACT(DAY FROM date)::INTEGER AS day_of_month,
    EXTRACT(WEEK FROM date)::INTEGER AS week,
    EXTRACT(MONTH FROM date)::INTEGER AS month,
    EXTRACT(QUARTER FROM date)::INTEGER AS quarter,
    EXTRACT(YEAR FROM date)::INTEGER AS year,
    TO_CHAR(date, 'Mon') AS month_name,
    TO_CHAR(date, 'Dy') AS weekday_name
FROM calendar;
