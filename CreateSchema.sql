SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE Category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE Product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    name VARCHAR(100),
    description TEXT,
    price DECIMAL(10, 2),
    stock_quantity INT
);

CREATE TABLE Customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    password VARCHAR(100)
);

CREATE TABLE `Order` (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2)
);

CREATE TABLE Order_details (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2)
);

ALTER TABLE Product
ADD CONSTRAINT fk_product_category
FOREIGN KEY (category_id) REFERENCES Category(category_id);

ALTER TABLE `Order`
ADD CONSTRAINT fk_order_customer
FOREIGN KEY (customer_id) REFERENCES Customer(customer_id);

ALTER TABLE Order_details
ADD CONSTRAINT fk_orderdetails_order
FOREIGN KEY (order_id) REFERENCES `Order`(order_id);

ALTER TABLE Order_details
ADD CONSTRAINT fk_orderdetails_product
FOREIGN KEY (product_id) REFERENCES Product(product_id);

SET FOREIGN_KEY_CHECKS = 1;
