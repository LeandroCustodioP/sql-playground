-- 🟡 Intermediate SQL Exercises
-- More complex queries involving multiple joins, subqueries, and aggregations

--------------------------------------------------------------------------------
-- Exercise I1: Best Selling Products by Category
--------------------------------------------------------------------------------
-- Description: Practice subqueries, joins, and aggregations
-- Task: Find the best-selling product in each category
-- Expected: Category name, product name, total quantity sold
-- Note: Consider using window functions or subqueries

-- Your solution here:
-- SELECT ...

/*
-- Solution:
WITH product_sales AS (
    SELECT 
        c.category_name,
        p.product_name,
        COALESCE(SUM(oi.quantity), 0) as total_sold,
        ROW_NUMBER() OVER (PARTITION BY c.category_id ORDER BY SUM(oi.quantity) DESC) as rank
    FROM categories c
    JOIN products p ON c.category_id = p.category_id
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY c.category_id, c.category_name, p.product_name
)
SELECT 
    category_name,
    product_name,
    total_sold
FROM product_sales
WHERE rank = 1;
*/

--------------------------------------------------------------------------------
-- Exercise I2: Customer Purchase Patterns
--------------------------------------------------------------------------------
-- Description: Analyze customer behavior with date functions and aggregations
-- Task: For each customer, show their:
--       - Total amount spent
--       - Average order value
--       - Days between first and last order
--       - Number of different categories purchased
-- Expected: Customer name and the calculated metrics

-- Your solution here:
-- SELECT ...

/*
-- Solution:
SELECT 
    c.customer_name,
    SUM(oi.quantity * oi.unit_price_cents) as total_spent_cents,
    ROUND(AVG(oi.quantity * oi.unit_price_cents), 2) as avg_order_value_cents,
    EXTRACT(DAY FROM MAX(o.order_ts) - MIN(o.order_ts)) as days_between_orders,
    COUNT(DISTINCT p.category_id) as categories_bought
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY total_spent_cents DESC;
*/

--------------------------------------------------------------------------------
-- Exercise I3: Product Rating Analysis
--------------------------------------------------------------------------------
-- Description: Complex aggregations with conditional logic
-- Task: For each product with at least 3 reviews, show:
--       - Average rating
--       - Number of reviews
--       - Percentage of reviews that are 4 or 5 stars
--       - Most common rating (mode)
-- Expected: Product details and rating metrics

-- Your solution here:
-- SELECT ...

/*
-- Solution:
SELECT 
    p.product_name,
    COUNT(r.review_id) as review_count,
    ROUND(AVG(r.rating), 2) as avg_rating,
    ROUND(100.0 * COUNT(CASE WHEN r.rating >= 4 THEN 1 END) / COUNT(*), 2) as pct_high_ratings,
    MODE() WITHIN GROUP (ORDER BY r.rating) as most_common_rating
FROM products p
JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name
HAVING COUNT(r.review_id) >= 3
ORDER BY avg_rating DESC;
*/

--------------------------------------------------------------------------------
-- Exercise I4: Order Fulfillment Analysis
--------------------------------------------------------------------------------
-- Description: Time-based calculations and status tracking
-- Task: Analyze the order fulfillment process:
--       - Time from order to payment
--       - Time from payment to shipping
--       - Time from shipping to delivery
--       - Total fulfillment time
-- Note: Consider handling NULL values appropriately

-- Your solution here:
-- SELECT ...

/*
-- Solution:
SELECT 
    o.order_id,
    o.order_status,
    EXTRACT(HOUR FROM p.paid_ts - o.order_ts) as hours_to_payment,
    EXTRACT(HOUR FROM s.shipped_ts - p.paid_ts) as hours_to_ship,
    EXTRACT(HOUR FROM s.delivered_ts - s.shipped_ts) as hours_to_deliver,
    EXTRACT(HOUR FROM s.delivered_ts - o.order_ts) as total_fulfillment_hours
FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id
LEFT JOIN shipments s ON o.order_id = s.order_id
WHERE o.order_status = 'delivered'
ORDER BY total_fulfillment_hours;
*/