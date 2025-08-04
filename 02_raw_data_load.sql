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

-- Load the complete raw data from the global superstore dataset in this table using the following command:
-- COPY raw_data FROM '/path/to/global_superstore.csv' DELIMITER ',' CSV HEADER;