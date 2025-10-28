# Database Documentation

[English](#english) | [Português](#português)

## English

### Schema Overview
This database simulates an e-commerce platform with customers, products, orders, and related entities.

### Tables Description

#### Core Tables
1. **customers**
   - Primary key: `customer_id` (UUID)
   - Customer basic information (name, email)
   - Creation timestamp

2. **categories**
   - Primary key: `category_id` (UUID)
   - Product categorization
   - Unique category names

3. **products**
   - Primary key: `product_id` (UUID)
   - References: `category_id` → categories
   - Product details (name, description, price)
   - Creation timestamp

4. **orders**
   - Primary key: `order_id` (UUID)
   - References: `customer_id` → customers
   - Order status: pending, paid, shipped, delivered
   - Order timestamp
   - Shipping country

#### Transaction Tables
5. **order_items**
   - Composite primary key: (`order_id`, `product_id`)
   - References: `order_id` → orders, `product_id` → products
   - Quantity and unit price at time of purchase

6. **payments**
   - Primary key: `payment_id` (UUID)
   - References: `order_id` → orders
   - Payment method: card, pix, boleto, paypal
   - Amount and payment timestamp

7. **shipments**
   - Primary key: `shipment_id` (UUID)
   - References: `order_id` → orders (unique)
   - Shipping details (carrier, tracking)
   - Shipped and delivered timestamps

8. **reviews**
   - Primary key: `review_id` (UUID)
   - References: `product_id` → products, `customer_id` → customers
   - Rating (1-5) and comment
   - Creation timestamp
   - Unique constraint: one review per customer per product

### Views

1. **v_order_totals**
   - Order summary with total amount
   - Joins orders and order_items

2. **v_product_metrics**
   - Product performance metrics
   - Shows units sold, revenue, order count

### Example Queries

#### Basic Queries
```sql
-- List all products in a category
SELECT p.* 
FROM products p
JOIN categories c USING (category_id)
WHERE c.name = 'Electronics';

-- Find customer's last order
SELECT o.* 
FROM orders o
WHERE customer_id = :customer_id
ORDER BY order_ts DESC 
LIMIT 1;
```

#### Analytics Queries
```sql
-- Sales by category
SELECT 
    c.name as category,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(oi.qty) as units_sold,
    SUM(oi.qty * oi.unit_price_cents)/100.0 as revenue
FROM categories c
JOIN products p USING (category_id)
JOIN order_items oi USING (product_id)
JOIN orders o USING (order_id)
GROUP BY c.category_id, c.name
ORDER BY revenue DESC;

-- Customer purchase frequency
SELECT 
    c.name,
    COUNT(DISTINCT o.order_id) as total_orders,
    AVG(oi.qty * oi.unit_price_cents)/100.0 as avg_order_value
FROM customers c
JOIN orders o USING (customer_id)
JOIN order_items oi USING (order_id)
GROUP BY c.customer_id, c.name
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY avg_order_value DESC;
```

---

## Português

### Visão Geral do Schema
Este banco de dados simula uma plataforma de e-commerce com clientes, produtos, pedidos e entidades relacionadas.

### Descrição das Tabelas

#### Tabelas Principais
1. **customers** (Clientes)
   - Chave primária: `customer_id` (UUID)
   - Informações básicas do cliente (nome, email)
   - Data de criação

2. **categories** (Categorias)
   - Chave primária: `category_id` (UUID)
   - Categorização de produtos
   - Nomes de categoria únicos

3. **products** (Produtos)
   - Chave primária: `product_id` (UUID)
   - Referência: `category_id` → categories
   - Detalhes do produto (nome, descrição, preço)
   - Data de criação

4. **orders** (Pedidos)
   - Chave primária: `order_id` (UUID)
   - Referência: `customer_id` → customers
   - Status: pending, paid, shipped, delivered
   - Data do pedido
   - País de entrega

#### Tabelas Transacionais
5. **order_items** (Itens do Pedido)
   - Chave primária composta: (`order_id`, `product_id`)
   - Referências: `order_id` → orders, `product_id` → products
   - Quantidade e preço unitário no momento da compra

6. **payments** (Pagamentos)
   - Chave primária: `payment_id` (UUID)
   - Referência: `order_id` → orders
   - Método de pagamento: card, pix, boleto, paypal
   - Valor e data do pagamento

7. **shipments** (Envios)
   - Chave primária: `shipment_id` (UUID)
   - Referência: `order_id` → orders (único)
   - Detalhes do envio (transportadora, rastreamento)
   - Datas de envio e entrega

8. **reviews** (Avaliações)
   - Chave primária: `review_id` (UUID)
   - Referências: `product_id` → products, `customer_id` → customers
   - Nota (1-5) e comentário
   - Data de criação
   - Restrição única: uma avaliação por cliente por produto

### Views

1. **v_order_totals**
   - Resumo do pedido com valor total
   - Join entre orders e order_items

2. **v_product_metrics**
   - Métricas de desempenho do produto
   - Mostra unidades vendidas, receita, contagem de pedidos

### Exemplos de Queries

#### Queries Básicas
```sql
-- Listar todos os produtos de uma categoria
SELECT p.* 
FROM products p
JOIN categories c USING (category_id)
WHERE c.name = 'Eletrônicos';

-- Encontrar último pedido do cliente
SELECT o.* 
FROM orders o
WHERE customer_id = :customer_id
ORDER BY order_ts DESC 
LIMIT 1;
```

#### Queries Analíticas
```sql
-- Vendas por categoria
SELECT 
    c.name as categoria,
    COUNT(DISTINCT o.order_id) as total_pedidos,
    SUM(oi.qty) as unidades_vendidas,
    SUM(oi.qty * oi.unit_price_cents)/100.0 as receita
FROM categories c
JOIN products p USING (category_id)
JOIN order_items oi USING (product_id)
JOIN orders o USING (order_id)
GROUP BY c.category_id, c.name
ORDER BY receita DESC;

-- Frequência de compra por cliente
SELECT 
    c.name as cliente,
    COUNT(DISTINCT o.order_id) as total_pedidos,
    AVG(oi.qty * oi.unit_price_cents)/100.0 as valor_medio_pedido
FROM customers c
JOIN orders o USING (customer_id)
JOIN order_items oi USING (order_id)
GROUP BY c.customer_id, c.name
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY valor_medio_pedido DESC;
```
