-- ============================================================
-- FACT TABLE: fact_procurement_reliability
-- PURPOSE:
-- Build PO-level supplier reliability fact table.
-- ============================================================

DROP TABLE IF EXISTS fact_procurement_reliability;

CREATE TABLE fact_procurement_reliability AS
SELECT
    po_id,
    supplier_id,
    product_id,
    location_id,
    order_date,
    promised_date,
    actual_receipt_date,
    ordered_qty,
    received_qty,
    CASE
        WHEN promised_date IS NOT NULL AND order_date IS NOT NULL
            THEN (promised_date - order_date)
        ELSE NULL
    END AS planned_lead_time_days,
    CASE
        WHEN actual_receipt_date IS NOT NULL AND order_date IS NOT NULL
            THEN (actual_receipt_date - order_date)
        ELSE NULL
    END AS actual_lead_time_days,
    CASE
        WHEN actual_receipt_date IS NOT NULL AND promised_date IS NOT NULL
            THEN (actual_receipt_date - promised_date)
        ELSE NULL
    END AS lead_time_deviation,
    CASE
        WHEN received_qty >= ordered_qty THEN 1
        ELSE 0
    END AS in_full_receipt_flag,
    CASE
        WHEN actual_receipt_date IS NOT NULL
         AND promised_date IS NOT NULL
         AND actual_receipt_date > promised_date THEN 1
        ELSE 0
    END AS late_po_flag
FROM stg_suppliers;
