--- insert_categories
DELIMITER //
CREATE PROCEDURE insert_categories(IN start_from INT, IN num_rows INT)
BEGIN
  DECLARE i INT DEFAULT 0;
  WHILE i < num_rows DO
    INSERT INTO Category (category_name)
    VALUES (CONCAT('Category_', start_from + i));
    SET i = i + 1;
  END WHILE;
END //
DELIMITER ;

--- insert_products
DELIMITER //
CREATE PROCEDURE insert_products(IN start_from INT, IN num_rows INT)
BEGIN
  DECLARE i INT DEFAULT 0;
  DECLARE cat_count INT;

  SELECT COUNT(*) INTO cat_count FROM Category;

  WHILE i < num_rows DO
    INSERT INTO Product (category_id, name, description, price, stock_quantity)
    VALUES (
      MOD(start_from + i, cat_count) + 1,
      CONCAT('Product_', start_from + i),
      CONCAT('Description of product_', start_from + i),
      ROUND(RAND() * 1000, 2),
      FLOOR(RAND() * 1000)
    );
    SET i = i + 1;
  END WHILE;
END //
DELIMITER ;

--- insert_customers
DELIMITER //
CREATE PROCEDURE insert_customers(IN start_from INT, IN num_rows INT)
BEGIN
  DECLARE i INT DEFAULT 0;
  WHILE i < num_rows DO
    INSERT INTO Customer (first_name, last_name, email, password)
    VALUES (
      CONCAT('First_', start_from + i),
      CONCAT('Last_', start_from + i),
      CONCAT('user_', start_from + i, '@mail.com'),
      '1234'
    );
    SET i = i + 1;
  END WHILE;
END //
DELIMITER ;

--- insert_orders
DELIMITER //
CREATE PROCEDURE insert_orders(IN start_from INT, IN num_rows INT)
BEGIN
  DECLARE i INT DEFAULT 0;
  DECLARE cust_count INT;

  SELECT COUNT(*) INTO cust_count FROM Customer;

  WHILE i < num_rows DO
    INSERT INTO `Order` (customer_id, order_date, total_amount)
    VALUES (
      MOD(start_from + i, cust_count) + 1,
      CURDATE() - INTERVAL FLOOR(RAND()*365) DAY,
      ROUND(RAND()*1000, 2)
    );
    SET i = i + 1;
  END WHILE;
END //
DELIMITER ;

--- insert_orders
DELIMITER //
CREATE PROCEDURE insert_order_details(IN start_from INT, IN num_rows INT)
BEGIN
  DECLARE i INT DEFAULT 0;
  DECLARE order_count INT;
  DECLARE product_count INT;

  SELECT COUNT(*) INTO order_count FROM `Order`;
  SELECT COUNT(*) INTO product_count FROM Product;

  WHILE i < num_rows DO
    INSERT INTO Order_details (order_id, product_id, quantity, unit_price)
    VALUES (
      MOD(start_from + i, order_count) + 1,
      MOD(start_from + i, product_count) + 1,
      FLOOR(RAND()*10) + 1,
      ROUND(RAND()*500, 2)
    );
    SET i = i + 1;
  END WHILE;
END //
DELIMITER ;
