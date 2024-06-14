-- create the databases
CREATE DATABASE IF NOT EXISTS rustdb;

-- create the users for each database
CREATE USER 'math'@'%' IDENTIFIED BY 'math';
GRANT CREATE, ALTER, INDEX, LOCK TABLES, REFERENCES, UPDATE, DELETE, DROP, SELECT, INSERT ON `rustdb`.* TO 'math'@'%';

FLUSH PRIVILEGES;

CREATE TABLE customers (
    customer_id INT IDENTITY (1,1) PRIMARY KEY NOT NULL,
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    address NVARCHAR(255) NOT NULL,
    email NVARCHAR(100) NOT NULL,
    password NVARCHAR(255) NOT NULL,
);

CREATE TABLE products (
    product_id INT VARCHAR (50) PRIMARY KEY NOT NULL,
    product_name NVARCHAR(100) NOT NULL,
    price FLOAT NOT NULL,
    category NVARCHAR(100) NOT NULL,
    image VARBINARY(MAX),
    pcs_per_box INT NOT NULL,
    max_boxes_per_pallet INT NOT NULL,
    pcs_per_pallet AS (pcs_per_box * max_boxes_per_pallet) PERSISTED,
    pcs_per_truck AS (pcs_per_box * max_boxes_per_pallet * 33) PERSISTED,
);

CREATE TABLE stocks (
    product_id VARCHAR(50) PRIMARY KEY,
    qty INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE orders (
    order_id INT IDENTITY (1,1) PRIMARY KEY NOT NULL,
    customer_id INT,
    order_date VARCHAR(50) DEFAULT CONVERT(VARCHAR(50), GETDATE(), 20),
    delivery_date VARCHAR(50) DEFAULT CONVERT(VARCHAR(50), DATEADD(HOUR, 1, GETDATE()), 20),
    customer_address NVARCHAR(255),
    customer_full_name NVARCHAR(255),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
);

CREATE TABLE order_details (
    detail_id INT IDENTITY (1,1) PRIMARY KEY NOT NULL,
    order_id INT,
    product_id VARCHAR(50) NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    total_price FLOAT,
    total_price_tax FLOAT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
);

