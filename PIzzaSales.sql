# Pizza Sales EDA MySQL server #

# Setting up the environment for SQL #

#The datasets were loaded as Tables using the table data import wizard#

# order_details table, orders table, pizza_types table, pizza table #

# Query 1 #
# How much is the revenue generated from the pizza sales? #

select round( sum(od.quantity*p.price),2) as total_revenue
from order_details od
Join pizzas p
ON od.pizza_id=p.pizza_id;

#Query 2
# How is the customer's behavior? #

WITH order_value AS(
    SELECT
        od.order_id,
        SUM(od.quantity*p.price) AS order_total
    FROM order_details od
    JOIN pizzas p
        ON od.pizza_id = p.pizza_id
    GROUP BY od.order_id
)
SELECT
    ROUND (AVG(order_total), 2) AS avg_order_value
FROM order_value;

#Query 3
# What are the busiest days of the week? #

SELECT
    CASE DAYOFWEEK(date)
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
        END AS day_name,
          COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY day_name
ORDER BY total_orders DESC
LIMIT 7;

#Query 4
# In which time are the rush hours? #

SELECT 
    HOUR(time) AS order_hour,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY order_hour
ORDER BY total_orders DESC;

#Query 5
# Which pizza category is the best seller using revenues? #
SELECT
    pt.category,
    ROUND(SUM(od.quantity * p.price),2) AS revenue
FROM order_details od
JOIN pizzas p
    ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY revenue DESC;

#Query 6
# What are the TOP 5 pizzas sold in each category? #
# Classic Category #
SELECT
    pt.name AS pizza_name,
    pt.category,
    ROUND (SUM(od.quantity*p.price),2) AS revenue
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
WHERE pt.category IN ('Classic')
GROUP BY pt.name, pt.category
ORDER BY revenue DESC
LIMIT 5;

#Query 7
# What are the TOP 5 pizzas sold in each category? #
# Supreme Category #
SELECT
    pt.name AS pizza_name,
    pt.category,
    ROUND (SUM(od.quantity*p.price),2) AS revenue
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
WHERE pt.category IN ('Supreme')
GROUP BY pt.name, pt.category
ORDER BY revenue DESC
LIMIT 5;

#Query 8
# What are the TOP 5 pizzas sold in each category? #
# Chicken Category #
SELECT
    pt.name AS pizza_name,
    pt.category,
    ROUND (SUM(od.quantity*p.price),2) AS revenue
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
WHERE pt.category IN ('Chicken')
GROUP BY pt.name, pt.category
ORDER BY revenue DESC
LIMIT 5;

#Query 9
# What are the TOP 5 pizzas sold in each category? #
# Veggie Category #
SELECT
    pt.name AS pizza_name,
    pt.category,
    ROUND (SUM(od.quantity*p.price),2) AS revenue
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
WHERE pt.category IN ('Veggie')
GROUP BY pt.name, pt.category
ORDER BY revenue DESC
LIMIT 5;

#Query 10:
#Weak products or those with low customers demand and generate low revenues#
#The quantity sold is *less than 800 pizzas* and generated *less than R10 000#

SELECT 
    pt.name AS pizza_name,
    p.size,
    pt.category,
    SUM(od.quantity) AS pizzas_sold,
    ROUND(SUM(od.quantity*p.price),2) AS revenue
FROM order_details od
JOIN pizzas p
    ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name, p.size, pt.category
HAVING
    SUM(od.quantity)<800
    AND SUM(od.quantity*p.price)<10000
ORDER BY revenue ASC
Limit 10;

#Query 11 
# Confirming total count of weak SKUs flagged above #.

SELECT COUNT(*) AS weak_sku_count
FROM (
    SELECT 
        pt.name,
        p.size,
        pt.category,
        SUM(od.quantity) AS pizzas_sold,
        SUM(od.quantity*p.price) AS revenue
    FROM order_details od
    JOIN pizzas p
        ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt
        ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.name, p.size, pt.category
    HAVING
        SUM(od.quantity) < 800
        AND SUM(od.quantity*p.price) < 10000
) AS weak_skus;