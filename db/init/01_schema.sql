-- criar schema e extensões necessárias
CREATE SCHEMA IF NOT EXISTS app;
SET search_path TO app, public;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";  -- fornece uuid_generate_v4()
CREATE EXTENSION IF NOT EXISTS citext;       -- usado para coluna CITEXT
CREATE EXTENSION IF NOT EXISTS pgcrypto;     -- fornece funções criptográficas  

CREATE TABLE IF NOT EXISTS orders (
order_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
customer_id UUID NOT NULL REFERENCES customers(customer_id),
status TEXT NOT NULL CHECK (status IN ('pending','paid','shipped','delivered','cancelled','refunded')),
order_ts TIMESTAMPTZ NOT NULL DEFAULT NOW(),
shipping_country CHAR(2) REFERENCES countries(country_code)
);

-- Segurança básica: criar esquema isolado
CREATE TABLE IF NOT EXISTS payments (
payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
method TEXT NOT NULL CHECK (method IN ('card','pix','boleto','paypal')),
amount_cents INT NOT NULL CHECK (amount_cents >= 0),
paid_ts TIMESTAMPTZ
);


CREATE TABLE IF NOT EXISTS shipments (
shipment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
order_id UUID NOT NULL UNIQUE REFERENCES orders(order_id) ON DELETE CASCADE,
carrier TEXT,
tracking TEXT,
shipped_ts TIMESTAMPTZ,
delivered_ts TIMESTAMPTZ
);


CREATE TABLE IF NOT EXISTS reviews (
review_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
product_id UUID NOT NULL REFERENCES products(product_id),
customer_id UUID NOT NULL REFERENCES customers(customer_id),
rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
comment TEXT,
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
UNIQUE (product_id, customer_id)
);


-- Índices práticos
CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_payments_order ON payments(order_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_reviews_product ON reviews(product_id);


-- Views úteis para treino
CREATE OR REPLACE VIEW v_order_totals AS
SELECT
o.order_id,
o.customer_id,
o.order_ts,
SUM(oi.qty * oi.unit_price_cents) AS total_cents
FROM orders o
JOIN order_items oi USING (order_id)
GROUP BY 1,2,3;


CREATE OR REPLACE VIEW v_product_metrics AS
SELECT
p.product_id,
p.name,
p.category_id,
SUM(oi.qty) AS units_sold,
SUM(oi.qty * oi.unit_price_cents) AS gross_revenue_cents,
COUNT(DISTINCT oi.order_id) AS order_count
FROM products p
LEFT JOIN order_items oi USING (product_id)
GROUP BY 1,2,3;