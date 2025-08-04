CREATE TABLE raw_data (
    row_id          INTEGER,
    order_id        TEXT,
    order_date      TEXT,
    ship_date       TEXT,
    ship_mode       TEXT,
    customer_id     TEXT,
    customer_name   TEXT,
    segment         TEXT,
    city            TEXT,
    state           TEXT,
    country         TEXT,
    postal_code     TEXT,
    market          TEXT,
    region          TEXT,
    product_id      TEXT,
    category        TEXT,
    sub_category    TEXT,
    product_name    TEXT,
    sales           TEXT,
    quantity        TEXT,
    discount        TEXT,
    profit          TEXT,
    shipping_cost   TEXT,
    order_priority  TEXT
);

-- Data Insertion into Normalized Tables

-- Extracts unique customer information from raw_data, ensuring only one entry per customer_id
INSERT INTO customers (customer_id, customer_name, segment)
SELECT DISTINCT ON (customer_id) -- This ensures only one row per unique customer_id
    customer_id,
    customer_name,
    segment
FROM raw_data
WHERE customer_id IS NOT NULL AND TRIM(customer_id) <> ''
  AND customer_name IS NOT NULL AND TRIM(customer_name) <> ''
  AND segment IS NOT NULL AND TRIM(segment) <> ''
ORDER BY customer_id, customer_name, segment -- ORDER BY is required for DISTINCT ON
;

-- 2. Insert into Geography
-- Extracts unique geographical information from raw_data
INSERT INTO geography (country, market, region, state, city, postal_code)
SELECT DISTINCT
    country,
    market,
    region,
    state,
    city,
    CASE WHEN TRIM(postal_code) = '' THEN NULL ELSE postal_code END -- Handle empty strings as NULL for postal_code
FROM raw_data
WHERE country IS NOT NULL AND TRIM(country) <> ''
  AND market IS NOT NULL AND TRIM(market) <> ''
  AND region IS NOT NULL AND TRIM(region) <> ''
  AND state IS NOT NULL AND TRIM(state) <> ''
  AND city IS NOT NULL AND TRIM(city) <> ''
;

-- 3. Insert into Products (Already corrected in previous step)
-- Extracts unique product information from raw_data, ensuring only one entry per product_id
INSERT INTO products (product_id, product_name, category, sub_category)
SELECT DISTINCT ON (product_id) -- This ensures only one row per unique product_id
    product_id,
    product_name,
    category,
    sub_category
FROM raw_data
WHERE product_id IS NOT NULL AND TRIM(product_id) <> ''
  AND product_name IS NOT NULL AND TRIM(product_name) <> ''
  AND category IS NOT NULL AND TRIM(category) <> ''
  AND sub_category IS NOT NULL AND TRIM(sub_category) <> ''
ORDER BY product_id, product_name, category, sub_category -- ORDER BY is required for DISTINCT ON to determine which row is picked
;

-- 4. Insert into Orders
-- Extracts order details and links to customers and geography using JOINs
INSERT INTO orders (
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    geo_id,
    order_priority
)
SELECT DISTINCT ON (rd.order_id) -- Ensures only one entry per unique order_id
    rd.order_id,
    CAST(rd.order_date AS DATE),
    CAST(rd.ship_date AS DATE),
    rd.ship_mode,
    c.customer_id,
    g.geo_id,
    rd.order_priority
FROM raw_data rd
JOIN customers c ON rd.customer_id = c.customer_id
JOIN geography g ON rd.country = g.country
                 AND rd.market = g.market
                 AND rd.region = g.region
                 AND rd.state = g.state
                 AND rd.city = g.city
                 AND (TRIM(rd.postal_code) = '' OR rd.postal_code = g.postal_code) -- Handle postal code matching, allowing for NULLs
WHERE rd.order_id IS NOT NULL AND TRIM(rd.order_id) <> ''
  AND rd.order_date IS NOT NULL AND TRIM(rd.order_date) <> ''
  AND rd.ship_date IS NOT NULL AND TRIM(rd.ship_date) <> ''
  AND rd.ship_mode IS NOT NULL AND TRIM(rd.ship_mode) <> ''
  AND rd.order_priority IS NOT NULL AND TRIM(rd.order_priority) <> ''
ORDER BY rd.order_id, rd.order_date -- Add ORDER BY for DISTINCT ON
;

-- 5. Insert into Order Details
-- Extracts line-item details and links to orders and products
INSERT INTO order_details (
    order_id,
    product_id,
    quantity,
    sales,
    discount,
    profit,
    shipping_cost
)
SELECT DISTINCT ON (od.order_id, od.product_id) -- Ensures unique order_id, product_id combinations
    od.order_id,
    od.product_id,
    CAST(od.quantity AS INTEGER),
    CAST(od.sales AS DECIMAL(12,2)),
    CAST(od.discount AS DECIMAL(5,2)),
    CAST(od.profit AS DECIMAL(12,2)),
    CAST(od.shipping_cost AS DECIMAL(12,2))
FROM raw_data od
JOIN orders o ON od.order_id = o.order_id
JOIN products p ON od.product_id = p.product_id
WHERE od.quantity IS NOT NULL AND TRIM(od.quantity) <> ''
  AND od.sales IS NOT NULL AND TRIM(od.sales) <> ''
  AND od.discount IS NOT NULL AND TRIM(od.discount) <> ''
  AND od.profit IS NOT NULL AND TRIM(od.profit) <> ''
  AND od.shipping_cost IS NOT NULL AND TRIM(od.shipping_cost) <> ''
ORDER BY od.order_id, od.product_id -- Add ORDER BY for DISTINCT ON
;