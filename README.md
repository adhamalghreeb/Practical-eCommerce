# Practical-eCommerce

## 1.1 ERD
![here the use case diagram](ERD.png)

## Entity Relationships
Customer → Order
Type: One-to-Many
-
Order → Order_details
Type: One-to-Many
-
Order_details → Product
Type: One-to-One
-
Category → Product
Type: One-to-Many
-
