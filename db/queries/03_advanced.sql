-- 🔴 Advanced SQL Exercises
-- Complex queries using window functions, CTEs, and advanced SQL features

--------------------------------------------------------------------------------
-- Exercise A1: Customer Cohort Analysis
--------------------------------------------------------------------------------
-- Description: Analyze customer behavior by signup cohort
-- Task: For each monthly cohort (signup month):
--       - Number of customers in cohort
--       - Orders in 1st month, 2nd month, 3rd month
--       - Revenue in 1st month, 2nd month, 3rd month
--       - Retention rate for each month
-- Hint: Use date_trunc and window functions

-- Your solution here:
-- SELECT ...

/*
-- Solution:
WITH customer_cohorts AS (
    SELECT
        customer_id,
        date_trunc('month', created_at) as cohort_month
    FROM customers
),
customer_activity AS (
    SELECT
        cc.customer_id,
        cc.cohort_month,
        DATE_PART('month', AGE(date_trunc('month', o.order_ts),
  cc.cohort_month)) as months_since_signup,
        COUNT(DISTINCT o.order_id) as orders,
        COALESCE(SUM(oi.quantity * oi.unit_price_cents), 0) as revenue_cents
    FROM customer_cohorts cc
    LEFT JOIN orders o ON cc.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY 1, 2, 3
)
SELECT
    cohort_month,
    COUNT(DISTINCT customer_id) as cohort_size,
    SUM(CASE WHEN months_since_signup = 0 THEN orders END) as month_0_orders,
    SUM(CASE WHEN months_since_signup = 1 THEN orders END) as month_1_orders,
    SUM(CASE WHEN months_since_signup = 2 THEN orders END) as month_2_orders,
    ROUND(SUM(CASE WHEN months_since_signup = 0 THEN revenue_cents END)::numeric,
  2) as month_0_revenue,
    ROUND(SUM(CASE WHEN months_since_signup = 1 THEN revenue_cents END)::numeric,
  2) as month_1_revenue,
    ROUND(SUM(CASE WHEN months_since_signup = 2 THEN revenue_cents END)::numeric,
  2) as month_2_revenue
FROM customer_activity
GROUP BY cohort_month
ORDER BY cohort_month;
*/

--------------------------------------------------------------------------------
-- Exercise A2: Product Affinity Analysis
--------------------------------------------------------------------------------
-- Description: Find products frequently bought together
-- Task: Identify pairs of products that are often purchased in the same order
-- Expected: Product A, Product B, number of times bought together
-- Note: Ensure each pair is counted only once (A,B same as B,A)

-- Your solution here:
-- SELECT ...

/*
-- Solution:
WITH order_products AS (
    SELECT DISTINCT
        o.order_id,
        p.product_id,
        p.product_name
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
)
SELECT
    p1.product_name as product_a,
    p2.product_name as product_b,
    COUNT(*) as bought_together_count
FROM order_products p1
JOIN order_products p2 ON p1.order_id = p2.order_id
    AND p1.product_id < p2.product_id  -- Ensure each pair is counted only once
GROUP BY p1.product_name, p2.product_name
HAVING COUNT(*) > 1
ORDER BY bought_together_count DESC;
*/

--------------------------------------------------------------------------------
-- Exercise A3: Customer Segmentation
--------------------------------------------------------------------------------
-- Description: Segment customers using advanced analytics
-- Task: Categorize customers based on:
--       - Recency (days since last order)
--       - Frequency (number of orders)
--       - Monetary (total spent)
-- Create segments using percentiles/quartiles
-- Hint: Use NTILE and window functions

-- Your solution here:
-- SELECT ...

/*
-- Solution:
WITH customer_metrics AS (
    SELECT
        c.customer_id,
        c.customer_name,
        NOW() - MAX(o.order_ts) as days_since_last_order,
        COUNT(DISTINCT o.order_id) as order_count,
        COALESCE(SUM(oi.quantity * oi.unit_price_cents), 0) as total_spent_cents,
        NTILE(4) OVER (ORDER BY NOW() - MAX(o.order_ts)) as recency_score,
        NTILE(4) OVER (ORDER BY COUNT(DISTINCT o.order_id)) as frequency_score,
        NTILE(4) OVER (ORDER BY COALESCE(SUM(oi.quantity * oi.unit_price_cents),
  0)) as monetary_score
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_name,
    days_since_last_order,
    order_count,
    total_spent_cents,
    CASE
        WHEN (recency_score + frequency_score + monetary_score) >= 10 THEN 'VIP'
        WHEN (recency_score + frequency_score + monetary_score) >= 7 THEN 'High Value'
        WHEN (recency_score + frequency_score + monetary_score) >= 4 THEN 'Medium Value'
        ELSE 'Low Value'
    END as customer_segment
FROM customer_metrics
ORDER BY total_spent_cents DESC;
*/

--------------------------------------------------------------------------------
-- Exercise A4: Sales Forecasting
--------------------------------------------------------------------------------
-- Description: Use window functions and moving averages for forecasting
-- Task: Calculate for each product:
--       - Daily sales for last 30 days
--       - 7-day moving average
--       - Growth rate compared to previous period
--       - Simple forecast for next 7 days
-- Hint: Use LAG, LEAD, and window functions

-- Your solution here:
-- SELECT ...

/*
-- Solution:
WITH daily_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        date_trunc('day', o.order_ts) as sale_date,
        SUM(oi.quantity) as units_sold,
        SUM(oi.quantity * oi.unit_price_cents) as revenue_cents
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_ts >= NOW() - INTERVAL '30 days'
    GROUP BY 1, 2, 3
),
sales_metrics AS (
    SELECT
        product_name,
        sale_date,
        units_sold,
        revenue_cents,
        AVG(units_sold) OVER (
            PARTITION BY product_id
            ORDER BY sale_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) as moving_avg_units,
        LAG(units_sold, 7) OVER (
            PARTITION BY product_id
            ORDER BY sale_date
        ) as prev_period_units
    FROM daily_sales
)
SELECT
    product_name,
    sale_date,
    units_sold,
    moving_avg_units,
    ROUND(
        100.0 * (units_sold - prev_period_units) / NULLIF(prev_period_units, 0),
        2
    ) as growth_rate_pct,
    ROUND(moving_avg_units * (1 + COALESCE(
        (units_sold - prev_period_units)::float / NULLIF(prev_period_units, 0),
        0
    ))) as forecasted_units
FROM sales_metrics
WHERE sale_date >= NOW() - INTERVAL '7 days'
ORDER BY product_name, sale_date;
*/
