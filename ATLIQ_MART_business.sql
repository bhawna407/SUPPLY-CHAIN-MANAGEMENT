-- ============================================================
-- ATLIQ MART — BUSINESS QUESTIONS & INSIGHTS
-- File 2 of 2 | Dialect: MySQL
-- Tables: dim_customers, dim_date, dim_products,
--         dim_target_orders, fact_order_lines, fact_order_aggregate
-- ============================================================


-- ============================================================
-- SECTION 1: OVERALL SERVICE LEVEL PERFORMANCE
-- ============================================================

-- Q1. What are the overall OT%, IF%, and OTIF% vs targets?
-- Insight: Exposes the top-level service gap driving contract non-renewals.
SELECT
    ROUND(AVG(foa.on_time) * 100, 2)                          AS ot_pct,
    ROUND(AVG(foa.in_full) * 100, 2)                          AS if_pct,
    ROUND(AVG(foa.otif) * 100, 2)                             AS otif_pct,
    ROUND(AVG(dt.ontime_target_pct), 2)                       AS ot_target,
    ROUND(AVG(dt.infull_target_pct), 2)                       AS if_target,
    ROUND(AVG(dt.otif_target_pct), 2)                         AS otif_target,
    ROUND(AVG(foa.on_time) * 100 - AVG(dt.ontime_target_pct), 2) AS gap_ot,
    ROUND(AVG(foa.in_full) * 100 - AVG(dt.infull_target_pct), 2) AS gap_if,
    ROUND(AVG(foa.otif) * 100   - AVG(dt.otif_target_pct), 2)    AS gap_otif
FROM fact_order_aggregate foa
JOIN dim_customers dc    ON foa.customer_id = dc.customer_id
JOIN dim_target_orders dt ON foa.customer_id = dt.customer_id;


-- Q2. How many orders are failing On-Time and In-Full criteria?
-- Insight: Quantifies the operational backlog driving customer complaints.
SELECT
    COUNT(*)                                                   AS total_orders,
    SUM(CASE WHEN on_time = 0 THEN 1 ELSE 0 END)              AS late_orders,
    SUM(CASE WHEN in_full = 0 THEN 1 ELSE 0 END)              AS not_in_full_orders,
    SUM(CASE WHEN otif = 0 THEN 1 ELSE 0 END)                 AS failed_otif_orders,
    ROUND(SUM(CASE WHEN on_time = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_pct,
    ROUND(SUM(CASE WHEN in_full = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS not_in_full_pct
FROM fact_order_aggregate;


-- Q3. Monthly trend of OT%, IF%, OTIF%
-- Insight: Reveals if performance is improving, flat, or deteriorating over time.
SELECT
    dd.mmm_yy                                                  AS month,
    ROUND(AVG(foa.on_time) * 100, 2)                          AS ot_pct,
    ROUND(AVG(foa.in_full) * 100, 2)                          AS if_pct,
    ROUND(AVG(foa.otif) * 100, 2)                             AS otif_pct,
    COUNT(foa.order_id)                                        AS total_orders
FROM fact_order_aggregate foa
JOIN fact_order_lines fol ON foa.order_id = fol.order_id
JOIN dim_date dd           ON fol.order_placement_date = dd.date
GROUP BY dd.mmm_yy
ORDER BY MIN(fol.order_placement_date);


-- ============================================================
-- SECTION 2: PRODUCT FULFILLMENT & FILL RATES
-- ============================================================

-- Q4. What are the overall VOFR% and LIFR%?
-- Insight: VOFR high but LIFR low = bulk qty ships but individual SKUs are missed.
SELECT
    ROUND(SUM(delivery_qty) * 100.0 / NULLIF(SUM(order_qty), 0), 2)   AS vofr_pct,
    ROUND(
        SUM(CASE WHEN delivery_qty >= order_qty THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(*), 0), 2)                                       AS lifr_pct,
    COUNT(*)                                                            AS total_order_lines,
    SUM(CASE WHEN delivery_qty < order_qty THEN 1 ELSE 0 END)          AS incomplete_lines
FROM fact_order_lines;


-- Q5. Fill rate breakdown by product category
-- Insight: Identifies which categories (Dairy / Food / Beverages) drive incompletion.
SELECT
    dp.category,
    COUNT(fol.order_id)                                                AS total_lines,
    ROUND(SUM(fol.delivery_qty) * 100.0 / NULLIF(SUM(fol.order_qty), 0), 2) AS vofr_pct,
    ROUND(
        SUM(CASE WHEN fol.delivery_qty >= fol.order_qty THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(*), 0), 2)                                      AS lifr_pct,
    SUM(fol.order_qty - fol.delivery_qty)                             AS total_qty_shortfall
FROM fact_order_lines fol
JOIN dim_products dp ON fol.product_id = dp.product_id
GROUP BY dp.category
ORDER BY lifr_pct ASC;


-- Q6. Top 10 products with the highest quantity shortfall
-- Insight: Pinpoints specific SKUs for safety stock reprioritisation.
SELECT
    dp.product_name,
    dp.category,
    SUM(fol.order_qty)                                                 AS total_ordered,
    SUM(fol.delivery_qty)                                              AS total_delivered,
    SUM(fol.order_qty - fol.delivery_qty)                             AS qty_shortfall,
    ROUND(SUM(fol.delivery_qty) * 100.0 / NULLIF(SUM(fol.order_qty), 0), 2) AS fill_rate_pct
FROM fact_order_lines fol
JOIN dim_products dp ON fol.product_id = dp.product_id
GROUP BY dp.product_name, dp.category
ORDER BY qty_shortfall DESC
LIMIT 10;


-- Q7. Average days to deliver and delivery delay distribution
-- Insight: Low average hides high variance — the real problem is inconsistency.
SELECT
    ROUND(AVG(DATEDIFF(actual_delivery_date, order_placement_date)), 2) AS avg_days_to_deliver,
    ROUND(AVG(DATEDIFF(actual_delivery_date, agreed_delivery_date)), 2) AS avg_delay_days,
    SUM(CASE WHEN actual_delivery_date > agreed_delivery_date THEN 1 ELSE 0 END) AS late_deliveries,
    SUM(CASE WHEN actual_delivery_date <= agreed_delivery_date THEN 1 ELSE 0 END) AS on_time_deliveries,
    MAX(DATEDIFF(actual_delivery_date, agreed_delivery_date))           AS max_delay_days
FROM fact_order_lines;


-- ============================================================
-- SECTION 3: CUSTOMER VULNERABILITY & CONTRACT RISK
-- ============================================================

-- Q8. OTIF% per customer vs their individual targets
-- Insight: Surfaces the highest-risk accounts for contract churn.
SELECT
    dc.customer_name,
    dc.city,
    COUNT(foa.order_id)                                                AS total_orders,
    ROUND(AVG(foa.on_time) * 100, 2)                                  AS ot_pct,
    ROUND(AVG(foa.in_full) * 100, 2)                                  AS if_pct,
    ROUND(AVG(foa.otif) * 100, 2)                                     AS otif_pct,
    ROUND(AVG(dt.otif_target_pct), 2)                                 AS otif_target,
    ROUND(AVG(foa.otif) * 100 - AVG(dt.otif_target_pct), 2)          AS gap_vs_target
FROM fact_order_aggregate foa
JOIN dim_customers dc     ON foa.customer_id = dc.customer_id
JOIN dim_target_orders dt  ON foa.customer_id = dt.customer_id
GROUP BY dc.customer_name, dc.city
ORDER BY otif_pct ASC;


-- Q9. Which customers have the highest volume of late orders?
-- Insight: Identifies where operational delay is most concentrated by customer.
SELECT
    dc.customer_name,
    dc.city,
    COUNT(foa.order_id)                                                AS total_orders,
    SUM(CASE WHEN foa.on_time = 0 THEN 1 ELSE 0 END)                  AS late_orders,
    ROUND(SUM(CASE WHEN foa.on_time = 0 THEN 1 ELSE 0 END) * 100.0
          / NULLIF(COUNT(*), 0), 2)                                    AS late_order_pct
FROM fact_order_aggregate foa
JOIN dim_customers dc ON foa.customer_id = dc.customer_id
GROUP BY dc.customer_name, dc.city
ORDER BY late_orders DESC;


-- Q10. Average delivery delay per customer
-- Insight: Shows which customers are absorbing the worst delays.
SELECT
    dc.customer_name,
    dc.city,
    ROUND(AVG(DATEDIFF(fol.actual_delivery_date, fol.agreed_delivery_date)), 2) AS avg_delay_days,
    MAX(DATEDIFF(fol.actual_delivery_date, fol.agreed_delivery_date))           AS max_delay_days,
    COUNT(fol.order_id)                                                         AS total_lines
FROM fact_order_lines fol
JOIN dim_customers dc ON fol.customer_id = dc.customer_id
GROUP BY dc.customer_name, dc.city
ORDER BY avg_delay_days DESC;


-- ============================================================
-- SECTION 4: GEOGRAPHIC PERFORMANCE BREAKDOWN
-- ============================================================

-- Q11. OT%, IF%, OTIF% by city vs targets
-- Insight: Shows which city is the regional laggard (Vadodara confirmed weakest).
SELECT
    dc.city,
    COUNT(foa.order_id)                                                AS total_orders,
    ROUND(AVG(foa.on_time) * 100, 2)                                  AS ot_pct,
    ROUND(AVG(foa.in_full) * 100, 2)                                  AS if_pct,
    ROUND(AVG(foa.otif) * 100, 2)                                     AS otif_pct,
    ROUND(AVG(dt.otif_target_pct), 2)                                 AS otif_target,
    ROUND(AVG(foa.otif) * 100 - AVG(dt.otif_target_pct), 2)          AS gap_vs_target
FROM fact_order_aggregate foa
JOIN dim_customers dc     ON foa.customer_id = dc.customer_id
JOIN dim_target_orders dt  ON foa.customer_id = dt.customer_id
GROUP BY dc.city
ORDER BY otif_pct ASC;


-- Q12. Late orders and fill rate by city
-- Insight: Isolates whether each city's problem is a timing or quantity issue.
SELECT
    dc.city,
    COUNT(fol.order_id)                                                               AS total_lines,
    SUM(CASE WHEN fol.actual_delivery_date > fol.agreed_delivery_date THEN 1 ELSE 0 END) AS late_lines,
    ROUND(SUM(fol.delivery_qty) * 100.0 / NULLIF(SUM(fol.order_qty), 0), 2)          AS vofr_pct,
    ROUND(
        SUM(CASE WHEN fol.delivery_qty >= fol.order_qty THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(*), 0), 2)                                                     AS lifr_pct
FROM fact_order_lines fol
JOIN dim_customers dc ON fol.customer_id = dc.customer_id
GROUP BY dc.city
ORDER BY late_lines DESC;


-- ============================================================
-- SECTION 5: ADVANCED PROBLEM-SOLVING QUERIES
-- ============================================================

-- Q13. Which customer-product combinations have the worst fill rates?
-- Insight: Enables surgical safety stock decisions at customer-SKU level.
SELECT
    dc.customer_name,
    dp.product_name,
    dp.category,
    SUM(fol.order_qty)                                                              AS total_ordered,
    SUM(fol.delivery_qty)                                                           AS total_delivered,
    ROUND(SUM(fol.delivery_qty) * 100.0 / NULLIF(SUM(fol.order_qty), 0), 2)       AS fill_rate_pct,
    SUM(fol.order_qty - fol.delivery_qty)                                          AS qty_shortfall
FROM fact_order_lines fol
JOIN dim_customers dc ON fol.customer_id = dc.customer_id
JOIN dim_products dp  ON fol.product_id  = dp.product_id
GROUP BY dc.customer_name, dp.product_name, dp.category
HAVING fill_rate_pct < 80
ORDER BY qty_shortfall DESC
LIMIT 15;


-- Q14. Weekly late order spike detection
-- Insight: Flags specific weeks with abnormal delay spikes for root cause analysis.
SELECT
    dd.week_no,
    COUNT(foa.order_id)                                                AS total_orders,
    SUM(CASE WHEN foa.on_time = 0 THEN 1 ELSE 0 END)                  AS late_orders,
    ROUND(SUM(CASE WHEN foa.on_time = 0 THEN 1 ELSE 0 END) * 100.0
          / NULLIF(COUNT(*), 0), 2)                                    AS late_pct
FROM fact_order_aggregate foa
JOIN fact_order_lines fol ON foa.order_id = fol.order_id
JOIN dim_date dd           ON fol.order_placement_date = dd.date
GROUP BY dd.week_no
ORDER BY late_pct DESC;


-- Q15. Revenue loss estimation from failed OTIF orders
-- Insight: Converts service failures into financial impact for executive reporting.
SELECT
    dc.customer_name,
    dc.city,
    COUNT(foa.order_id)                                                AS total_orders,
    SUM(CASE WHEN foa.otif = 0 THEN 1 ELSE 0 END)                     AS failed_otif_orders,
    ROUND(SUM(CASE WHEN foa.otif = 0 THEN 1 ELSE 0 END) * 100.0
          / NULLIF(COUNT(*), 0), 2)                                    AS failure_rate_pct,
    -- Qty shortfall on failed OTIF orders as a proxy for revenue at risk
    SUM(CASE WHEN foa.otif = 0 THEN (fol.order_qty - fol.delivery_qty) ELSE 0 END) AS lost_qty
FROM fact_order_aggregate foa
JOIN dim_customers dc    ON foa.customer_id = dc.customer_id
JOIN fact_order_lines fol ON foa.order_id   = fol.order_id
GROUP BY dc.customer_name, dc.city
ORDER BY lost_qty DESC;


-- Q16. Repeat late deliveries — customers receiving chronic delays
-- Insight: Customers with >50% late order rate are immediate churn risks.
SELECT
    dc.customer_name,
    dc.city,
    COUNT(foa.order_id)                                                AS total_orders,
    SUM(CASE WHEN foa.on_time = 0 THEN 1 ELSE 0 END)                  AS late_orders,
    ROUND(SUM(CASE WHEN foa.on_time = 0 THEN 1 ELSE 0 END) * 100.0
          / NULLIF(COUNT(*), 0), 2)                                    AS late_pct,
    CASE
        WHEN ROUND(SUM(CASE WHEN foa.on_time = 0 THEN 1 ELSE 0 END) * 100.0
             / NULLIF(COUNT(*), 0), 2) >= 60 THEN 'Critical Risk'
        WHEN ROUND(SUM(CASE WHEN foa.on_time = 0 THEN 1 ELSE 0 END) * 100.0
             / NULLIF(COUNT(*), 0), 2) >= 40 THEN 'High Risk'
        ELSE 'Moderate'
    END                                                                AS risk_flag
FROM fact_order_aggregate foa
JOIN dim_customers dc ON foa.customer_id = dc.customer_id
GROUP BY dc.customer_name, dc.city
ORDER BY late_pct DESC;


-- Q17. City + Category OTIF cross-analysis
-- Insight: Reveals if Vadodara's weakness is across all categories or category-specific.
SELECT
    dc.city,
    dp.category,
    COUNT(fol.order_id)                                                              AS total_lines,
    ROUND(SUM(fol.delivery_qty) * 100.0 / NULLIF(SUM(fol.order_qty), 0), 2)        AS vofr_pct,
    SUM(CASE WHEN fol.actual_delivery_date > fol.agreed_delivery_date THEN 1 ELSE 0 END) AS late_lines,
    ROUND(SUM(CASE WHEN fol.actual_delivery_date > fol.agreed_delivery_date THEN 1 ELSE 0 END)
          * 100.0 / NULLIF(COUNT(*), 0), 2)                                         AS late_pct
FROM fact_order_lines fol
JOIN dim_customers dc ON fol.customer_id = dc.customer_id
JOIN dim_products dp  ON fol.product_id  = dp.product_id
GROUP BY dc.city, dp.category
ORDER BY dc.city, late_pct DESC;


-- Q18. Are expansion-ready thresholds being met? (OTIF >= 50% check)
-- Insight: Hard gate — expansion should be blocked until this threshold is cleared.
SELECT
    dc.city,
    ROUND(AVG(foa.otif) * 100, 2)                                     AS current_otif_pct,
    50.00                                                              AS expansion_threshold,
    CASE
        WHEN ROUND(AVG(foa.otif) * 100, 2) >= 50 THEN 'Ready to Expand'
        ELSE 'NOT Ready — Fix First'
    END                                                                AS expansion_status
FROM fact_order_aggregate foa
JOIN dim_customers dc ON foa.customer_id = dc.customer_id
GROUP BY dc.city;


-- ============================================================
-- END OF FILE — 18 QUERIES ACROSS 5 SECTIONS
-- ============================================================
