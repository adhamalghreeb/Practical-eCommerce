-- use database
USE ecommerce;

-- code
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
