 -- Project: Exploratory Data Analysis (EDA)  

-- Explore all objects in the Database

SELECT * FROM INFORMATION_SCHEMA.TABLES;

-- Explore all columns in the Database

SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'dim_customers'

-- Explore all  countries our customers come from

SELECT DISTINCT COUNTRY FROM gold.dim_customers;

-- Explore all categories "The major Divisions"

SELECT DISTINCT category,subcategory, product_name FROM gold.dim_products
ORDER BY 1, 2, 3;

-- Find the date of the first and last order
-- How many years of sales are available 

SELECT 
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	DATEDIFF(year, MIN(order_date), MAX(order_date)) AS order_range
FROM gold.fact_sales;

-- Find yongestst and oldest customer

SELECT 
	MIN(birth_day) AS oldest_birth_date,
	DATEDIFF(YEAR, MIN(birth_day), GETDATE()) AS oldest_age,
	MAX(birth_day) AS yongest_birthdate,
	DATEDIFF(YEAR, MAX(birth_day), GETDATE()) AS youngest_age
FROM gold.dim_customers;

SELECT * FROM  gold.fact_sales;
SELECT * FROM  gold.dim_customers;
SELECT * FROM  gold.dim_products;

----------------------------
-- Mesure exploration------
---------------------------


SELECT * FROM  gold.fact_sales;
SELECT * FROM  gold.dim_customers;
SELECT * FROM  gold.dim_products;



-- 1 Find the total sales

Select sum(sales_amount) AS total_sales 
from gold.fact_sales;


-- 2 Find how many items are sold

Select sum(quantity) AS items_counts
from gold.fact_sales;

-- 3 Find the total number of orders

SELECT COUNT ( DISTINCT order_number ) AS total_orders FROM gold.fact_sales;

-- 4 Find the total number of products

SELECT COUNT(distinct product_name) AS total_products FROM gold.dim_products;

-- 5 Find the total number of customers
SELECT COUNT(DISTINCT customer_ID) FROM gold.dim_customers;

-- 6 Find the total number of customers that has placed an order

SELECT COUNT(DISTINCT customer_key) AS total_customers FROM  gold.fact_sales

-- 7 find  the avg price 
SELECT AVG(price) FROM gold.fact_sales

--- Generate a report that shows all key metrics of the business


Select 'Total sales' AS measure_name, sum(sales_amount) AS measure_value  from gold.fact_sales
UNION ALL
Select 'total quantity', sum(quantity) from gold.fact_sales
UNION ALL
SELECT 'total_orders', COUNT ( DISTINCT order_number ) FROM gold.fact_sales
UNION ALL
SELECT 'Average price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total nr. products',  COUNT(distinct product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total No. Customers', COUNT(DISTINCT customer_key) FROM  gold.fact_sales;


SELECT 'LAVA' AS NAME, 'HERO' AS ROLE
UNION ALL
SELECT 'SIDHIKSHA' AS NAME, 'VILLAIN' AS ROLE;

SELECT 'LAVA' AS NAME, 'FATHER' AS FAMILY_ROLE
UNION ALL
SELECT 'MAMATHA', 'MOTHER'
UNION ALL
SELECT 'SIDHIKSHA', 'DAUGHTER'
UNION ALL
SELECT 'N/A', 'SON'


-------------------------------------


SELECT * FROM  gold.fact_sales;
SELECT * FROM  gold.dim_customers;
SELECT * FROM  gold.dim_products;


-- Find total customers by countries

SELECT country, COUNT(DISTINCT customer_id) AS total_customers FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Find total customers by gender

SELECT gender, count(gender) AS total FROM  gold.dim_customers
GROUP BY Gender
ORDER BY total desc;

-- Find total products by category

SELECT category, COUNT(product_key) AS totaL_products
FROM  gold.dim_products
GROUP BY category
ORDER BY totaL_products DESC;


-- What is the average costs in each category?
SELECT category, AVG(cost) AS avg_cost FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost desc;


-- What is the total revenue generated for each category?

SELECT P.category, SUM(sales_amount) totat_revenue FROM  gold.dim_products p
INNER JOIN gold.fact_sales F
ON P.product_key = F.product_key
GROUP BY P.category
ORDER BY totat_revenue DESC;

-- Find total revenue is generated by each customer

SELECT c.customer_key, c.first_name, c.last_name, sum(f.sales_amount) as total_rev
from gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS C
ON  c.customer_key = f.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_rev DESC;

-- What is the distribution of sold items across countries?

SELECT c.country, sum(f.quantity) AS total
from gold.fact_sales AS f
INNER JOIN gold.dim_customers AS c
ON c.customer_ID = f.customer_key
GROUP BY c.country
ORDER BY total DESC;


----------- RANKING ANALYSIS -----------

--- SQL TASK ---

--- 1, which 5 products generated the highest revenue 

SELECT * FROM  gold.fact_sales;
SELECT * FROM  gold.dim_customers;
SELECT * FROM  gold.dim_products;


SELECT TOP 5 p.product_name, 
SUM(f.sales_amount) as totat_revenu 
FROM gold.fact_sales f 
LEFT JOIN gold.dim_products p 
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY totat_revenu  DESC;

-- USING WINDOWS FUNCTION
SELECT * FROM
(
SELECT P.product_name,
SUM(f.sales_amount) as totat_revenu,
ROW_NUMBER() OVER( ORDER BY SUM(f.sales_amount) DESC) AS RANK_NUMBER
FROM gold.fact_sales f 
LEFT JOIN gold.dim_products p 
ON p.product_key = f.product_key
GROUP BY p.product_name
)T
WHERE RANK_NUMBER < = 5;



--2, What are the 5 worst-performing products in terms of sales

SELECT TOP 5 p.product_name, 
SUM(f.sales_amount) as totat_revenu 
FROM gold.fact_sales f 
LEFT JOIN gold.dim_products p 
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY totat_revenu ASC ;


-- USING WINDOWS FUNCTION 
SELECT * FROM
(
SELECT P.product_name,
SUM(f.sales_amount) as totat_revenu,
ROW_NUMBER() OVER( ORDER BY SUM(f.sales_amount) ASC) AS RANK_NUMBER
FROM gold.fact_sales f 
LEFT JOIN gold.dim_products p 
ON p.product_key = f.product_key
GROUP BY p.product_name
)T
WHERE RANK_NUMBER < = 5;


-- 3, Find the top-10  customers who have generated the highest revenue

SELECT TOP 10 
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) as Total_sales
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY
	c.customer_key, 
	c.first_name,
	c.last_name
ORDER BY Total_sales DESC

--4,  3 customers with the fest orders placed

SELECT TOP 3
	c.customer_key,
	c.first_name,
	c.last_name,
COUNT( DISTINCT f.order_number) as order_count
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY
	c.customer_key, 
	c.first_name,
	c.last_name
ORDER BY order_count asc
