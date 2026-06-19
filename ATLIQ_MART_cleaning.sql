-- ============================================================
-- ATLIQ MART — SUPPLY CHAIN DATA CLEANING
-- File 1 of 2 | Dialect: MySQL
-- Tables: dim_customers, dim_date, dim_products,
--         dim_target_orders, fact_order_lines, fact_order_aggregate
-- ============================================================


-- ============================================================
-- SECTION 1: ROW COUNTS & INITIAL INSPECTION
-- ============================================================

-- Total rows per table
SELECT 'dim_customers'       AS table_name, COUNT(*) AS row_count FROM dim_customers
UNION ALL
SELECT 'dim_date',                          COUNT(*) FROM dim_date
UNION ALL
SELECT 'dim_products',                      COUNT(*) FROM dim_products
UNION ALL
SELECT 'dim_target_orders',                 COUNT(*) FROM dim_target_orders
UNION ALL
SELECT 'fact_order_lines',                  COUNT(*) FROM fact_order_lines
UNION ALL
SELECT 'fact_order_aggregate',              COUNT(*) FROM fact_order_aggregate;


-- Preview each table
SELECT * FROM dim_customers       LIMIT 5;
SELECT * FROM dim_date            LIMIT 5;
SELECT * FROM dim_products        LIMIT 5;
SELECT * FROM dim_target_orders   LIMIT 5;
SELECT * FROM fact_order_lines    LIMIT 5;
SELECT * FROM fact_order_aggregate LIMIT 5;


-- ============================================================
-- SECTION 2: NULL / MISSING VALUE CHECKS
-- ============================================================

-- dim_customers
SELECT
    SUM(CASE WHEN customer_id   IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS null_customer_name,
    SUM(CASE WHEN city          IS NULL THEN 1 ELSE 0 END) AS null_city
FROM dim_customers;

-- dim_products
SELECT
    SUM(CASE WHEN product_id   IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS null_product_name,
    SUM(CASE WHEN category     IS NULL THEN 1 ELSE 0 END) AS null_category
FROM dim_products;

-- dim_target_orders
SELECT
    SUM(CASE WHEN customer_id         IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN ontime_target_pct   IS NULL THEN 1 ELSE 0 END) AS null_ontime_target,
    SUM(CASE WHEN infull_target_pct   IS NULL THEN 1 ELSE 0 END) AS null_infull_target,
    SUM(CASE WHEN otif_target_pct     IS NULL THEN 1 ELSE 0 END) AS null_otif_target
FROM dim_target_orders;

-- fact_order_lines (most critical table)
SELECT
    SUM(CASE WHEN order_id               IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN customer_id            IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN product_id             IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN order_placement_date   IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN agreed_delivery_date   IS NULL THEN 1 ELSE 0 END) AS null_agreed_date,
    SUM(CASE WHEN actual_delivery_date   IS NULL THEN 1 ELSE 0 END) AS null_actual_date,
    SUM(CASE WHEN order_qty              IS NULL THEN 1 ELSE 0 END) AS null_order_qty,
    SUM(CASE WHEN delivery_qty           IS NULL THEN 1 ELSE 0 END) AS null_delivery_qty
FROM fact_order_lines;

-- fact_order_aggregate
SELECT
    SUM(CASE WHEN order_id       IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN customer_id    IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN on_time        IS NULL THEN 1 ELSE 0 END) AS null_on_time,
    SUM(CASE WHEN in_full        IS NULL THEN 1 ELSE 0 END) AS null_in_full,
    SUM(CASE WHEN otif            IS NULL THEN 1 ELSE 0 END) AS null_otif
FROM fact_order_aggregate;


-- ============================================================
-- SECTION 3: DUPLICATE CHECKS
-- ============================================================

-- Duplicate customer_ids
SELECT customer_id, COUNT(*) AS occurrences
FROM dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Duplicate product_ids
SELECT product_id, COUNT(*) AS occurrences
FROM dim_products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Duplicate order + product line combinations in fact_order_lines
SELECT order_id, product_id, COUNT(*) AS occurrences
FROM fact_order_lines
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

-- Duplicate order_ids in fact_order_aggregate (should be 1 row per order)
SELECT order_id, COUNT(*) AS occurrences
FROM fact_order_aggregate
GROUP BY order_id
HAVING COUNT(*) > 1;


-- ============================================================
-- SECTION 4: DATE VALIDITY CHECKS
-- ============================================================

-- Agreed delivery date should never be before order placement date
SELECT COUNT(*) AS invalid_date_sequence
FROM fact_order_lines
WHERE agreed_delivery_date < order_placement_date;

-- Actual delivery date should not be before order placement date
SELECT COUNT(*) AS delivery_before_order
FROM fact_order_lines
WHERE actual_delivery_date < order_placement_date;

-- Future-dated actual deliveries (data entry errors)
SELECT COUNT(*) AS future_deliveries
FROM fact_order_lines
WHERE actual_delivery_date > CURDATE();

-- Date range sanity
SELECT
    MIN(order_placement_date)  AS earliest_order,
    MAX(order_placement_date)  AS latest_order,
    MIN(actual_delivery_date)  AS earliest_delivery,
    MAX(actual_delivery_date)  AS latest_delivery
FROM fact_order_lines;


-- ============================================================
-- SECTION 5: QUANTITY VALIDITY CHECKS
-- ============================================================

-- Negative or zero quantities (invalid)
SELECT COUNT(*) AS invalid_order_qty
FROM fact_order_lines
WHERE order_qty <= 0;

SELECT COUNT(*) AS invalid_delivery_qty
FROM fact_order_lines
WHERE delivery_qty < 0;

-- Delivery qty exceeding order qty by more than 10% (over-delivery flag)
SELECT
    order_id,
    product_id,
    order_qty,
    delivery_qty,
    ROUND((delivery_qty - order_qty) * 100.0 / NULLIF(order_qty, 0), 2) AS over_delivery_pct
FROM fact_order_lines
WHERE delivery_qty > order_qty * 1.10
ORDER BY over_delivery_pct DESC
LIMIT 20;

-- Summary: delivery_qty vs order_qty distribution
SELECT
    MIN(delivery_qty)                                            AS min_delivery_qty,
    MAX(delivery_qty)                                           AS max_delivery_qty,
    ROUND(AVG(delivery_qty), 2)                                AS avg_delivery_qty,
    ROUND(AVG(order_qty), 2)                                   AS avg_order_qty,
    ROUND(SUM(delivery_qty) * 100.0 / NULLIF(SUM(order_qty), 0), 2) AS overall_volume_fill_pct
FROM fact_order_lines;


-- ============================================================
-- SECTION 6: REFERENTIAL INTEGRITY CHECKS
-- ============================================================

-- Orders with customer_id not in dim_customers
SELECT COUNT(*) AS orphan_orders
FROM fact_order_lines fol
LEFT JOIN dim_customers dc ON fol.customer_id = dc.customer_id
WHERE dc.customer_id IS NULL;

-- Orders with product_id not in dim_products
SELECT COUNT(*) AS orphan_product_lines
FROM fact_order_lines fol
LEFT JOIN dim_products dp ON fol.product_id = dp.product_id
WHERE dp.product_id IS NULL;

-- fact_order_aggregate orders not matched in fact_order_lines
SELECT COUNT(*) AS unmatched_aggregate_orders
FROM fact_order_aggregate foa
LEFT JOIN fact_order_lines fol ON foa.order_id = fol.order_id
WHERE fol.order_id IS NULL;

-- Customers in dim_target_orders not in dim_customers
SELECT COUNT(*) AS missing_target_customers
FROM dim_target_orders dt
LEFT JOIN dim_customers dc ON dt.customer_id = dc.customer_id
WHERE dc.customer_id IS NULL;


-- ============================================================
-- SECTION 7: CATEGORICAL VALUE CONSISTENCY
-- ============================================================

-- Distinct cities (check for typos / casing inconsistencies)
SELECT DISTINCT city, COUNT(*) AS customer_count
FROM dim_customers
GROUP BY city
ORDER BY city;

-- Distinct product categories
SELECT DISTINCT category, COUNT(*) AS product_count
FROM dim_products
GROUP BY category
ORDER BY category;

-- on_time and in_full flags should only be 0 or 1
SELECT DISTINCT on_time FROM fact_order_aggregate ORDER BY on_time;
SELECT DISTINCT in_full  FROM fact_order_aggregate ORDER BY in_full;
SELECT DISTINCT otif      FROM fact_order_aggregate ORDER BY otif;

-- Delivery_Delays should be >= 0 (negative = early delivery, flag for review)
SELECT COUNT(*) AS early_deliveries
FROM fact_order_lines
WHERE (DATEDIFF(actual_delivery_date, agreed_delivery_date)) < 0;

SELECT
    MIN(DATEDIFF(actual_delivery_date, agreed_delivery_date)) AS min_delay_days,
    MAX(DATEDIFF(actual_delivery_date, agreed_delivery_date)) AS max_delay_days,
    ROUND(AVG(DATEDIFF(actual_delivery_date, agreed_delivery_date)), 2) AS avg_delay_days
FROM fact_order_lines;


-- ============================================================
-- SECTION 8: CONSISTENCY BETWEEN FACT TABLES
-- ============================================================

-- OTIF flag in fact_order_aggregate should match on_time AND in_full
SELECT COUNT(*) AS otif_flag_mismatch
FROM fact_order_aggregate
WHERE otif != (on_time * in_full);

-- Cross-check: orders in fact_order_lines vs fact_order_aggregate
SELECT
    (SELECT COUNT(DISTINCT order_id) FROM fact_order_lines)     AS order_lines_distinct_orders,
    (SELECT COUNT(DISTINCT order_id) FROM fact_order_aggregate) AS aggregate_distinct_orders;


-- ============================================================
-- SECTION 9: STANDARDISATION (SAFE UPDATES)
-- ============================================================

-- Trim whitespace from customer names
UPDATE dim_customers
SET customer_name = TRIM(customer_name)
WHERE customer_name != TRIM(customer_name);

-- Trim whitespace from product names
UPDATE dim_products
SET product_name = TRIM(product_name)
WHERE product_name != TRIM(product_name);

-- Standardise city names to Title Case (Ahmedabad / Surat / Vadodara)
UPDATE dim_customers
SET city = CONCAT(UPPER(LEFT(LOWER(city), 1)), LOWER(SUBSTRING(city, 2)))
WHERE city != CONCAT(UPPER(LEFT(LOWER(city), 1)), LOWER(SUBSTRING(city, 2)));

-- Standardise category to Title Case
UPDATE dim_products
SET category = CONCAT(UPPER(LEFT(LOWER(category), 1)), LOWER(SUBSTRING(category, 2)))
WHERE category != CONCAT(UPPER(LEFT(LOWER(category), 1)), LOWER(SUBSTRING(category, 2)));


-- ============================================================
-- SECTION 10: ADD COMPUTED COLUMN FOR DELIVERY DELAY
-- ============================================================

-- Add Delivery_Delays column if not already present
ALTER TABLE fact_order_lines
ADD COLUMN IF NOT EXISTS delivery_delay_days INT
    GENERATED ALWAYS AS (DATEDIFF(actual_delivery_date, agreed_delivery_date)) STORED;

-- Add on_time_flag if not already present (1 = delivered on or before agreed date)
ALTER TABLE fact_order_lines
ADD COLUMN IF NOT EXISTS on_time_flag TINYINT(1)
    GENERATED ALWAYS AS (
        CASE WHEN actual_delivery_date <= agreed_delivery_date THEN 1 ELSE 0 END
    ) STORED;

-- Confirm computed columns
SELECT
    order_id,
    agreed_delivery_date,
    actual_delivery_date,
    delivery_delay_days,
    on_time_flag
FROM fact_order_lines
LIMIT 10;


-- ============================================================
-- END OF FILE — CLEANING COMPLETE
-- ============================================================
