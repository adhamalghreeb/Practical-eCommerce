-- use database
USE ecommerce;

-- code
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
