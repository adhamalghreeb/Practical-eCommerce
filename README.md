# 🛒 Practical-eCommerce

## 📘 1.1 ERD

![ERD Diagram](ERD.png)

## 📊 Entity Relationships

- **Customer → Order**  
  Type: One-to-Many

- **Order → Order_details**  
  Type: One-to-Many

- **Order_details → Product**  
  Type: One-to-One

- **Category → Product**  
  Type: One-to-Many

---
## 📦 Task 1: Create the Database Schema
```sql
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
```
## 📦 Task 2: Daily Revenue Report
```sql
USE ecommerce;

SELECT 
    order_date,
    SUM(total_amount) AS total_revenue
FROM 
    `Order`
GROUP BY 
    order_date
ORDER BY 
    order_date;
```
## 📦 Task 3: Monthly Top-Selling Products
```sql
USE ecommerce;

SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(od.quantity) AS total_quantity_sold,
    SUM(od.quantity * od.unit_price) AS total_revenue
FROM 
    Order_details od
JOIN 
    `Order` o ON od.order_id = o.order_id
JOIN 
    Product p ON od.product_id = p.product_id
WHERE 
    o.order_date BETWEEN '2025-05-01' AND '2025-05-31'
GROUP BY 
    p.product_id, p.name
ORDER BY 
    total_quantity_sold DESC;
```
---
## 📦 Task 4: High-Value Customers (Past Month)
```sql
USE ecommerce;

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(o.total_amount) AS total_spent
FROM 
    `Order` o
JOIN 
    Customer c ON o.customer_id = c.customer_id
WHERE 
    o.order_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 31 DAY)
                    AND DATE_SUB(CURDATE(), INTERVAL 1 DAY)
GROUP BY 
    c.customer_id, c.first_name, c.last_name
HAVING 
    total_spent > 500
ORDER BY 
    total_spent DESC;

```
---

## 🔄2.1 Denormalization Task: Flattening the Category Tree

In eCommerce systems, categories often form a hierarchical structure. To simplify access and improve performance (e.g., for breadcrumb navigation or filtering), we flatten the tree into a readable and queryable format.

### 🧱 Step 1: Create the Flattened Table

```sql
CREATE TABLE CategoryPath (
    CatID INT PRIMARY KEY,
    FullPath VARCHAR(1000),     -- e.g., "Electronics > Phones > iPhone"
    FullPathIDs VARCHAR(500),   -- e.g., "1 > 2 > 7"
    PathDepth INT               -- e.g., 3
);
```

### 🧱 Step 2: Recursive Query to Populate It

```sql
WITH RECURSIVE category_tree AS (
    -- Anchor: Root categories (no parent)
    SELECT 
        id,
        name,
        parent_id,
        CAST(name AS CHAR(1000)) AS full_path,
        CAST(id AS CHAR(1000)) AS full_path_ids,
        1 AS depth
    FROM categories
    WHERE parent_id IS NULL

    UNION ALL

    -- Recursive: Join children to parent paths
    SELECT 
        c.id,
        c.name,
        c.parent_id,
        CONCAT(ct.full_path, ' > ', c.name),
        CONCAT(ct.full_path_ids, ' > ', c.id),
        ct.depth + 1
    FROM categories c
    INNER JOIN category_tree ct ON c.parent_id = ct.id
)

-- Final output
SELECT 
    id AS CatID,
    full_path AS FullPath,
    full_path_ids AS FullPathIDs,
    depth AS PathDepth
FROM category_tree
ORDER BY FullPath;
```

### 🧱 Step 3: Automating Updates

use a scheduled job to refresh the entire CategoryPath table periodically

---

## 🔍 Task: Search Products with the Word "Camera"
### 📝 Solution 1: Basic LIKE Query

```sql
SELECT *
FROM Product
WHERE name LIKE '%camera%'
   OR description LIKE '%camera%';
```
⚠️ This query is not optimal for large datasets as it results in a full table scan due to the leading wildcard %.

### 📝 Solution 2: Optimized Full-Text Search
```sql
--- First, add a full-text index on the name and description columns:
ALTER TABLE Product 
ADD FULLTEXT(name, description);

--- Then use MATCH with AGAINST to perform a fast, indexed search:
SELECT *
FROM Product
WHERE MATCH(name, description) AGAINST('camera' IN NATURAL LANGUAGE MODE);
```

---

## 🔍 Task: Recommended top products forcustomer
```sql
SELECT 
    p.product_id,
    p.name,
    SUM(od.quantity) AS total_quantity_sold
FROM Products p
JOIN OrderDetails od ON p.product_id = od.product_id
WHERE NOT EXISTS ( --- remove products that customer did buy beofre
    SELECT 1
    FROM Orders o
    JOIN OrderDetails od2 ON o.order_id = od2.order_id
    WHERE o.customer_id = :givenCustomerId
      AND od2.product_id = p.product_id
)
AND (p.category_id, p.brand, p.company) IN ( --- filter by brand and company
    SELECT DISTINCT p.category_id, p.brand, p.company
    FROM Orders o
    JOIN OrderDetails od ON o.order_id = od.order_id
    JOIN Products p ON od.product_id = p.product_id
    WHERE o.customer_id = :givenCustomerId
)
GROUP BY p.product_id, p.name
ORDER BY total_quantity_sold DESC
```

---

## 🧾 Task: Table `sales_history`
The `sales_history` table stores a denormalized snapshot of each product sold in an order. It combines key data from multiple tables — including customer info, product details, and category — to enable fast reporting and analytics without joins.
This table is automatically populated whenever a new order is placed.
```sql
CREATE TABLE sales_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    order_date DATETIME,
    customer_id INT,
    customer_name VARCHAR(150),
    product_id INT,
    product_name VARCHAR(150),
    category_id INT,
    category_name VARCHAR(150),
    quantity INT,
    product_total DECIMAL(10, 2) --- this is for historcal purposes
    total_amount DECIMAL(10, 2),
);
```
- `product_total` stores the revenue generated by each product line (for historical price tracking).
- `total_amount` reflects the total value of the entire order.
