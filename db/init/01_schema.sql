-- Schema, extensão e tabelas principais para o playground
-- Cria um schema dedicado 'app' para que o script de seed possa usar
-- SET search_path TO app, public;
CREATE SCHEMA IF NOT EXISTS app;
SET search_path TO app, public;

-- Helper UUID (disponível no init como superusuário)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;

-- Clientes
CREATE TABLE IF NOT EXISTS customers (
    customer_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Categorias
CREATE TABLE IF NOT EXISTS categories (
    category_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE
);

-- Produtos
CREATE TABLE IF NOT EXISTS products (
	product_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	name TEXT NOT NULL,
	description TEXT,
	category_id UUID REFERENCES categories(category_id),
	price_cents INT NOT NULL CHECK (price_cents >= 0),
	created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Pedidos
CREATE TABLE IF NOT EXISTS orders (
    order_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('pending','paid','shipped','delivered')),
    order_ts TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    shipping_country TEXT
);

-- Itens do pedido (chave primária composta)
CREATE TABLE IF NOT EXISTS order_items (
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(product_id),
    qty INT NOT NULL CHECK (qty > 0),
    unit_price_cents INT NOT NULL CHECK (unit_price_cents >= 0),
    PRIMARY KEY (order_id, product_id)
);


CREATE TABLE IF NOT EXISTS payments (
    payment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    method TEXT NOT NULL CHECK (method IN ('card','pix','boleto','paypal')),
    amount_cents INT NOT NULL CHECK (amount_cents >= 0),
    paid_ts TIMESTAMPTZ
);


CREATE TABLE IF NOT EXISTS shipments (
    shipment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL UNIQUE REFERENCES orders(order_id) ON DELETE CASCADE,
    carrier TEXT,
    tracking TEXT,
    shipped_ts TIMESTAMPTZ,
    delivered_ts TIMESTAMPTZ
);


CREATE TABLE IF NOT EXISTS reviews (
    review_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES products(product_id),
    customer_id UUID NOT NULL REFERENCES customers(customer_id),
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (product_id, customer_id)
);


-- Índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_payments_order ON payments(order_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_reviews_product ON reviews(product_id);


-- Views úteis para análise
CREATE OR REPLACE VIEW v_order_totals AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_ts,
    SUM(oi.qty * oi.unit_price_cents) AS total_cents
FROM orders AS o
JOIN order_items AS oi USING (order_id)
GROUP BY 1,2,3;


CREATE OR REPLACE VIEW v_product_metrics AS
SELECT
    p.product_id,
    p.name,
    p.category_id,
    SUM(oi.qty) AS units_sold,
    SUM(oi.qty * oi.unit_price_cents) AS gross_revenue_cents,
    COUNT(DISTINCT oi.order_id) AS order_count
FROM products AS p
LEFT JOIN order_items AS oi USING (product_id)
GROUP BY 1,2,3;