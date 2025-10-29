# SQL Playground 🎮

[English](#english) | [Português](#português)

## English

### Overview
This is a ready-to-use SQL practice environment featuring a complete e-commerce database schema. Perfect for learning SQL, testing queries, and practicing database concepts without the hassle of setting up a complex environment.

### Features
- 📦 Complete e-commerce database schema
- 🔄 Sample data automatically generated
- � SQL practice exercises (basic to advanced)
- �🐳 Docker-based (runs anywhere)
- 🔌 Multiple access options
- 🔧 Easy to reset and modify

### Database Schema
The database includes the following tables:
- `customers` - Customer information
- `categories` - Product categories
- `products` - Product catalog
- `orders` - Customer orders
- `order_items` - Items in each order
- `payments` - Order payments
- `shipments` - Shipping information
- `reviews` - Product reviews

### Requirements
- Docker
- Docker Compose

### Quick Start
1. Clone the repository:
```bash
git clone https://github.com/LeandroCustodioP/sql-playground.git
cd sql-playground
```

2. Set up the environment:
```bash
cp .env.example .env  # Copy the example file and adjust if needed
```

3. Start the environment:
```bash
docker compose up -d
```

### Connecting to the Database
You can connect using any of these methods:

1. **Adminer (Web Interface)**
   - URL: http://localhost:8080
   - System: PostgreSQL
   - Server: db
   - User: app
   - Password: (from .env file)
   - Database: sql_playground

2. **PostgreSQL CLI**
```bash
docker compose exec db psql -U app -d sql_playground
```

3. **External Tools** (DBeaver, pgAdmin, etc)
   - Host: localhost
   - Port: 5432
   - Database: sql_playground
   - User: app
   - Password: (from .env file)

### Resetting the Database
To start fresh with a clean database:
```bash
docker compose down -v  # Removes everything including the volume
docker compose up -d   # Recreates everything from scratch
```

### Directory Structure
```
.
├── docker-compose.yml    # Docker environment configuration
├── db/
│   ├── init/
│   │   ├── 01_schema.sql  # Database schema
│   │   └── 02_seed.sql    # Sample data generation
│   ├── queries/           # SQL practice exercises
│   │   ├── 01_basic.sql      # Basic exercises
│   │   ├── 02_intermediate.sql # Intermediate exercises
│   │   ├── 03_advanced.sql    # Advanced exercises
│   │   └── README.md          # Exercise documentation
│   └── README.md          # Database documentation
```

---

## Português

### Visão Geral
Este é um ambiente prático de SQL pronto para uso, apresentando um esquema completo de banco de dados de e-commerce. Perfeito para aprender SQL, testar queries e praticar conceitos de banco de dados sem a complexidade de configurar um ambiente complexo.

### Características
- 📦 Esquema completo de banco de dados e-commerce
- 🔄 Dados de exemplo gerados automaticamente
- 🐳 Baseado em Docker (roda em qualquer lugar)
- 🔌 Múltiplas opções de acesso
- 🔧 Fácil de resetar e modificar

### Esquema do Banco de Dados
O banco inclui as seguintes tabelas:
- `customers` - Informações dos clientes
- `categories` - Categorias de produtos
- `products` - Catálogo de produtos
- `orders` - Pedidos dos clientes
- `order_items` - Itens em cada pedido
- `payments` - Pagamentos dos pedidos
- `shipments` - Informações de envio
- `reviews` - Avaliações dos produtos

### Requisitos
- Docker
- Docker Compose

### Início Rápido
1. Clone o repositório:
```bash
git clone https://github.com/LeandroCustodioP/sql-playground.git
cd sql-playground
```

2. Configure o ambiente:
```bash
cp .env.example .env  # Copie o arquivo de exemplo e ajuste se necessário
```

3. Inicie o ambiente:
```bash
docker compose up -d
```

### Conectando ao Banco de Dados
Você pode conectar usando qualquer um destes métodos:

1. **Adminer (Interface Web)**
   - URL: http://localhost:8080
   - Sistema: PostgreSQL
   - Servidor: db
   - Usuário: app
   - Senha: (do arquivo .env)
   - Banco de dados: sql_playground

2. **CLI do PostgreSQL**
```bash
docker compose exec db psql -U app -d sql_playground
```

3. **Ferramentas Externas** (DBeaver, pgAdmin, etc)
   - Host: localhost
   - Porta: 5432
   - Banco de dados: sql_playground
   - Usuário: app
   - Senha: (do arquivo .env)

### Resetando o Banco de Dados
Para começar do zero com um banco de dados limpo:
```bash
docker compose down -v  # Remove tudo, incluindo o volume
docker compose up -d   # Recria tudo do zero
```

### Estrutura de Diretórios
```
.
├── docker-compose.yml    # Configuração do ambiente Docker
├── db/
│   ├── init/
│   │   ├── 01_schema.sql  # Esquema do banco de dados
│   │   └── 02_seed.sql    # Geração de dados de exemplo
│   └── README.md          # Documentação do banco de dados
```