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

## 🔄 Denormalization Task: Flattening the Category Tree

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
