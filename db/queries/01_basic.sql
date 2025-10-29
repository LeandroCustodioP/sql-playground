-- 🟢 Basic SQL Exercises
-- Each exercise has a description, the task, hints (optional), and the solution (hidden below)

--------------------------------------------------------------------------------
-- Exercise B1: List All Products
--------------------------------------------------------------------------------
-- Description: Get familiar with basic SELECT and ORDER BY
-- Task: List all products ordered by price (most expensive first)
-- Expected: Product name, price (in cents), and category name

-- Your solution here:
-- SELECT ...

/*
-- Solution:
SELECT
    p.product_name,
    p.price_cents,
    c.category_name
FROM products p
JOIN categories c ON p.category_id = c.category_id
ORDER BY p.price_cents DESC;
*/

--------------------------------------------------------------------------------
-- Exercise B2: Recent Customers
--------------------------------------------------------------------------------
-- Description: Practice filtering with WHERE and date functions
-- Task: Find customers who joined in the last 7 days
-- Hint: Use the created_at field and interval arithmetic

-- Your solution here:
-- SELECT ...

/*
-- Solution:
SELECT
    customer_name,
    email,
    created_at
FROM customers
WHERE created_at >= NOW() - INTERVAL '7 days'
ORDER BY created_at DESC;
*/

--------------------------------------------------------------------------------
-- Exercise B3: Order Status Count
--------------------------------------------------------------------------------
-- Description: Introduction to GROUP BY and counting
-- Task: Count how many orders exist in each status
-- Expected: Status and count, sorted by count descending

-- Your solution here:
-- SELECT ...

/*
-- Solution:
SELECT
    order_status,
    COUNT(*) as status_count
FROM orders
GROUP BY order_status
ORDER BY status_count DESC;
*/

--------------------------------------------------------------------------------
-- Exercise B4: Products Without Orders
--------------------------------------------------------------------------------
-- Description: Practice LEFT JOIN and IS NULL
-- Task: Find all products that have never been ordered
-- Expected: Product name and price

-- Your solution here:
-- SELECT ...

/*
-- Solution:
SELECT
    p.product_name,
    p.price_cents
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL;
*/

--------------------------------------------------------------------------------
-- Exercise B5: Customer Order Summary
--------------------------------------------------------------------------------
-- Description: Combining JOIN and GROUP BY
-- Task: For each customer, show their name and how many orders they have
-- Expected: Customer name, email, and order count
-- Note: Include all customers, even those without orders

-- Your solution here:
-- SELECT ...

/*
-- Solution:
SELECT
    c.customer_name,
    c.email,
    COUNT(o.order_id) as order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.email
ORDER BY order_count DESC;
*/
