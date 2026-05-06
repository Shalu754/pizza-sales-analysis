-- =========================================
-- PIZZA SALES ANALYSIS - SQL QUERIES
-- =========================================


-- BASIC ANALYSIS : 

-- 1. Retrieve the total number of orders placed. 

select count(order_id) as total_orders
 from orders;

-- 2. calculate the total revenue generated from pizza sales. 

select round(sum(order_details.quantity * pizzas.price),0) as revenue
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id;

-- 3. Count total number of pizza types available. 

select count(distinct pizza_type_id) as total_pizza_types
from pizza_types;

-- 4. Find all available pizza sizes. 

select distinct size as total_availabe_sizes
from pizzas;

-- 5. Find total number of pizzas sold (overall quantity)

select sum(quantity) as total_pizza_sold
from order_details;

-- 6. Find total number of unique pizza names. 

select count(distinct name) as total_unique_pizzas
from pizza_types;

-- 7. Find earliest and latest order date. 

select min(order_date) as first_order,
max(order_date) as last_order
from orders;

-- 8. Identify the highest priced pizza(by unit price). 

select pizza_types.name, pizzas.price
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc limit 1;

-- 9. Determine the most frequently ordered pizza size. 

select pizzas.size, count(order_details.order_details_id) as order_count
from pizzas
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size order by order_count desc;

-- 10. List the top 5 most ordered pizza types based on total quantity. 

select pizza_types.name, sum(order_details.quantity) as quantity
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by quantity desc limit 5;


-- INTERMEDIATE ANALYSIS :


-- 11. Find orders with more than 5 pizzas. 

select order_id, sum(quantity) as total_quantity
from order_details
group by order_id having total_quantity >5; 

-- 12. Find average quantity per order. 

SELECT 
ROUND(SUM(quantity) / COUNT(DISTINCT order_id), 2) AS avg_quantity_per_order
FROM order_details;

-- 13. Find Total revenue per pizza size. 

select pizzas.size,
round(sum(order_details.quantity * pizzas.price),2) as revenue
from pizzas join order_details 
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by revenue desc;

-- 14. Find number of orders per day of week. 

select dayname(order_date) as day,
count(order_id) as total_orders
from orders
group by day 
order by total_orders desc;

-- 15. Find top 5 most expensive pizzas (by price). 

select pizza_id, price
from pizzas
order by price desc
limit 5;

-- 16. Find total quantity sold for each pizza size. 

select pizzas.size,
sum(order_details.quantity) as total_quantity
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by total_quantity desc;

-- 17. Find total orders placed each month. 

select month(order_date) as month,
count(order_id) as total_orders
from orders
group by month 
order by month;

-- 18. Calculate the total quantity of pizzas ordered for each category ( using JOIN ). 

select pizza_types.category,
sum(order_details.quantity) as quantity
from pizza_types 
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by quantity desc;

-- 19. Analyze the distribution of orders by hour of the day. 

select hour(order_time) as hour, count(order_id) as order_count
from orders 
group by hour(order_time);

-- 20. Determine the category-wise distribution of pizzas. 

select category, count(name) as distribution from pizza_types
group by category;

-- 21. Group the orders by date and calculate the average number of pizzas ordered per day. 

select round(avg(per_day_order),2) as per_day_order_avg
from
(select orders.order_date, sum(order_details.quantity) as per_day_order
from orders
join order_details on orders.order_id = order_details.order_id
group by orders.order_date) as order_quantity;


-- 22. Identify the top 3 pizza types based on total revenue generated. 

select pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types 
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by revenue desc limit 3;


-- ADVANCE ANALYSIS : 


-- 23. Calculate percentage contribution of each pizza type to total revenue. 

select pizza_types.category,
round(sum(order_details.quantity * pizzas.price) / 
( select round(sum(order_details.quantity *pizzas.price),2) as total_sales
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id) * 100,2) as revenue 
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by revenue desc; 

-- 24. Analyse the cumulative revenue generated over time. 

select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date,
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) sales;

-- 25. Determine the top 3 most ordered pizza types based on revenue for each pizza category. 

select category, name, revenue, ranks from
(select category, name, revenue, rank() over(partition by category order by revenue desc) as ranks 
from
(select pizza_types.category, pizza_types.name,
sum((order_details.quantity)*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a)b
where ranks<=3;
