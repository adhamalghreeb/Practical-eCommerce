-- use database
USE ecommerce;

-- code
SELECT 
    order_date,
    SUM(total_amount) AS total_revenue
FROM 
    `Order`
GROUP BY 
    order_date
ORDER BY 
    order_date;
