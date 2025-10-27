INSERT INTO products (sku, name, category_id, supplier_id, price_cents)
SELECT
  'EL-' || gs::TEXT,
  'Gadget ' || gs::TEXT,
  (SELECT category_id FROM categories WHERE name='Electronics'),
  (SELECT supplier_id FROM suppliers ORDER BY name OFFSET 1 LIMIT 1),
  9999 + (gs * 250)
FROM generate_series(1, 10) AS gs
ON CONFLICT DO NOTHING;


-- Inventory para todos os produtos
INSERT INTO inventory (product_id, qty_on_hand, reorder_level)
SELECT p.product_id, (random()*50)::INT + 10, 10
FROM products p
ON CONFLICT (product_id) DO NOTHING;


-- 20 pedidos com 1–3 itens cada
DO $$
DECLARE
c_id UUID;
o_id UUID;
p_id UUID;
i INT;
item_count INT;
BEGIN
FOR i IN 1..20 LOOP
SELECT customer_id INTO c_id FROM customers ORDER BY random() LIMIT 1;
INSERT INTO orders (order_id, customer_id, status, order_ts, shipping_country)
VALUES (uuid_generate_v4(), c_id,
(ARRAY['pending','paid','shipped','delivered'])[1 + (random()*3)::INT],
NOW() - ((random()*30)::INT || ' days')::interval,
(ARRAY['BR','US','GB'])[1 + (random()*2)::INT])
RETURNING order_id INTO o_id;


item_count := 1 + (random()*2)::INT;
FOR i IN 1..item_count LOOP
SELECT product_id INTO p_id FROM products ORDER BY random() LIMIT 1;
INSERT INTO order_items (order_id, product_id, qty, unit_price_cents)
SELECT o_id, p_id, 1 + (random()*3)::INT,
(SELECT price_cents FROM products WHERE product_id = p_id)
ON CONFLICT DO NOTHING;
END LOOP;


-- pagamento parcial/total
INSERT INTO payments (order_id, method, amount_cents, paid_ts)
SELECT o_id,
(ARRAY['card','pix','boleto','paypal'])[1 + (random()*3)::INT],
(SELECT COALESCE(SUM(qty*unit_price_cents),0) FROM order_items WHERE order_id=o_id),
NOW() - ((random()*25)::INT || ' days')::interval;


-- envio para parte dos pedidos
IF random() > 0.4 THEN
INSERT INTO shipments (order_id, carrier, tracking, shipped_ts, delivered_ts)
VALUES (o_id,'FastShip','TRK-' || substr(md5(random()::text),1,10),
NOW() - ((random()*20)::INT || ' days')::interval,
CASE WHEN random() > 0.5 THEN NOW() - ((random()*10)::INT || ' days')::interval END);
END IF;
END LOOP;
END $$;


-- Algumas reviews
INSERT INTO reviews (product_id, customer_id, rating, comment)
SELECT p.product_id, c.customer_id, 3 + (random()*2)::INT, 'Ótimo produto!'
FROM products p
JOIN customers c ON random() < 0.2
ON CONFLICT DO NOTHING;