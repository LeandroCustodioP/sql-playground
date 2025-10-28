-- Schema, extensão e tabelas principais para o playground
-- Cria um schema dedicado 'app' para que o script de seed possa usar
-- SET search_path TO app, public;
CREATE SCHEMA IF NOT EXISTS app;
SET search_path TO app, public;

-- Helper UUID (disponível no init como superusuário)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;

-- Clientes
CREATE TABLE IF NOT EXISTS customers (
    customer_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_name text NOT NULL,
    email text UNIQUE NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- Categorias
CREATE TABLE IF NOT EXISTS categories (
    category_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_name text NOT NULL UNIQUE
);

-- Produtos
CREATE TABLE IF NOT EXISTS products (
    product_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_name text NOT NULL,
    description text,
    category_id uuid REFERENCES categories (category_id),
    price_cents int NOT NULL CHECK (price_cents >= 0),
    created_at timestamptz NOT NULL DEFAULT now()
);-- Pedidos
CREATE TABLE IF NOT EXISTS orders (
    order_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id uuid NOT NULL REFERENCES customers (customer_id) ON DELETE CASCADE,
    order_status text NOT NULL CHECK (order_status IN ('pending', 'paid', 'shipped', 'delivered')),
    order_ts timestamptz NOT NULL DEFAULT now(),
    shipping_country text
);

-- Itens do pedido (chave primária composta)
CREATE TABLE IF NOT EXISTS order_items (
    order_id uuid NOT NULL REFERENCES orders (order_id) ON DELETE CASCADE,
    product_id uuid NOT NULL REFERENCES products (product_id),
    quantity int NOT NULL CHECK (quantity > 0),
    unit_price_cents int NOT NULL CHECK (unit_price_cents >= 0),
    PRIMARY KEY (order_id, product_id)
);


CREATE TABLE IF NOT EXISTS payments (
    payment_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id uuid NOT NULL REFERENCES orders (order_id) ON DELETE CASCADE,
    payment_method text NOT NULL CHECK (payment_method IN ('card', 'pix', 'boleto', 'paypal')),
    amount_cents int NOT NULL CHECK (amount_cents >= 0),
    paid_ts timestamptz
);


CREATE TABLE IF NOT EXISTS shipments (
    shipment_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id uuid NOT NULL UNIQUE REFERENCES orders (order_id) ON DELETE CASCADE,
    carrier text,
    tracking text,
    shipped_ts timestamptz,
    delivered_ts timestamptz
);


CREATE TABLE IF NOT EXISTS reviews (
    review_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id uuid NOT NULL REFERENCES products (product_id),
    customer_id uuid NOT NULL REFERENCES customers (customer_id),
    rating int NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_comment text,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (product_id, customer_id)
);


-- Índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders (customer_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product ON order_items (product_id);
CREATE INDEX IF NOT EXISTS idx_payments_order ON payments (order_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON products (category_id);
CREATE INDEX IF NOT EXISTS idx_reviews_product ON reviews (product_id);


-- Views úteis para análise
CREATE OR REPLACE VIEW v_order_totals AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_ts,
    sum(oi.quantity * oi.unit_price_cents) AS total_cents
FROM orders AS o
LEFT JOIN order_items AS oi ON o.order_id = oi.order_id
GROUP BY 1, 2, 3;


CREATE OR REPLACE VIEW v_product_metrics AS
SELECT
    p.product_id,
    p.product_name,
    p.category_id,
    sum(oi.quantity) AS units_sold,
    sum(oi.quantity * oi.unit_price_cents) AS gross_revenue_cents,
    count(DISTINCT oi.order_id) AS order_count
FROM products AS p
LEFT JOIN order_items AS oi ON p.product_id = oi.product_id
GROUP BY 1, 2, 3;
