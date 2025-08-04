-- Drop tables in reverse-dependency order to avoid foreign key conflicts during recreation
DROP TABLE IF EXISTS order_details CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS geography CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS raw_data; -- Drop raw_data last, as it has no dependencies

-- 1. Customers Table
-- Stores unique customer information
CREATE TABLE customers (
    customer_id   VARCHAR(20)   NOT NULL,
    customer_name VARCHAR(100)  NOT NULL,
    segment       VARCHAR(50)   NOT NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id)
);

-- 2. Geography Table
-- Stores unique geographical locations
CREATE TABLE geography (
    geo_id        SERIAL        NOT NULL, -- SERIAL auto-increments for unique IDs
    country       VARCHAR(50)   NOT NULL,
    market        VARCHAR(50)   NOT NULL,
    region        VARCHAR(50)   NOT NULL,
    state         VARCHAR(50)   NOT NULL,
    city          VARCHAR(50)   NOT NULL,
    postal_code   VARCHAR(30), -- Made nullable as postal codes can be missing for non-US data
    CONSTRAINT pk_geography PRIMARY KEY (geo_id),
    CONSTRAINT uq_geography UNIQUE (country, market, region, state, city, postal_code) -- Ensure unique geographical entries
);

-- 3. Products Table
-- Stores unique product information
CREATE TABLE products (
    product_id    VARCHAR(50)   NOT NULL,
    product_name  VARCHAR(150)  NOT NULL,
    category      VARCHAR(50)   NOT NULL,
    sub_category  VARCHAR(50)   NOT NULL,
    CONSTRAINT pk_products PRIMARY KEY (product_id)
);

-- 4. Orders Table
-- Stores order-level information, linking to customers and geography
CREATE TABLE orders (
    order_id      VARCHAR(50)   NOT NULL,
    order_date    DATE          NOT NULL,
    ship_date     DATE          NOT NULL,
    ship_mode     VARCHAR(50)   NOT NULL,
    customer_id   VARCHAR(20)   NOT NULL,
    geo_id        INT           NOT NULL,
    order_priority VARCHAR(20)  NOT NULL,
    CONSTRAINT pk_orders PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id),
    CONSTRAINT fk_orders_geo FOREIGN KEY (geo_id)
        REFERENCES geography (geo_id)
);

-- 5. Order Details Table
-- Stores line-item details for each order, linking to products
CREATE TABLE order_details (
    order_id      VARCHAR(50)   NOT NULL,
    product_id    VARCHAR(50)   NOT NULL,
    quantity      INT           NOT NULL,
    sales         DECIMAL(12,2) NOT NULL,
    discount      DECIMAL(5,2)  NOT NULL,
    profit        DECIMAL(12,2) NOT NULL,
    shipping_cost DECIMAL(12,2) NOT NULL,
    CONSTRAINT pk_order_details PRIMARY KEY (order_id, product_id), -- Composite primary key
    CONSTRAINT fk_od_orders FOREIGN KEY (order_id)
        REFERENCES orders (order_id),
    CONSTRAINT fk_od_products FOREIGN KEY (product_id)
        REFERENCES products (product_id)
);
