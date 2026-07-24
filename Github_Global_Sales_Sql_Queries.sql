
/*==============================================================
                    RETAIL SALES ANALYSIS
               SQL Exploratory Data Analysis (EDA)

Project : Retail Sales Analytics Dashboard

Database : PostgreSQL

Author : Hempreet Singh

Description:
This SQL file contains all queries used for exploratory
data analysis, customer analysis, product analysis,
sales analysis, regional analysis, and business insights
for the Retail Sales Analytics Dashboard.

==============================================================*/

/*==============================================================
SECTION 1 : DATA EXPLORATION
==============================================================*/

-- total customers count

SELECT COUNT(*) AS total_customers FROM customers

-- total gender count

SELECT gender, COUNT(*) AS total_customers FROM customers
GROUP BY gender

-- total customers count by state

SELECT state, 
       COUNT(*) AS total_customers 
	   FROM customers
       GROUP BY state
       ORDER BY total_customers DESC

-- count of customers by country

SELECT country, 
       COUNT(*) AS total_customers 
	   FROM customers
       GROUP BY country
       ORDER BY total_customers DESC


-- Customer Distribution by Age Group

SELECT
    CASE
        WHEN customer_age < 18 THEN 'Under 18'
        WHEN customer_age BETWEEN 18 AND 30 THEN '18-30'
        WHEN customer_age BETWEEN 31 AND 45 THEN '31-45'
        WHEN customer_age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END AS customer_group,
    COUNT(*) AS total_customers
FROM (
    SELECT EXTRACT(YEAR FROM AGE(
        (SELECT MAX(order_date) FROM sales),
        birthday
    ))::INT AS customer_age
    FROM customers
) t
GROUP BY customer_group
ORDER BY total_customers DESC;


-- count of total products by brand

SELECT brand, 
       COUNT(DISTINCT order_number) AS total_orders,
	   ROUND(SUM(unit_price_usd * quantity)::NUMERIC,2) AS total_revenue,
	   ROUND((SUM(unit_price_usd * quantity)*1.0/COUNT(DISTINCT order_number))::NUMERIC,2) AS AOV
	   FROM products p
	   JOIN sales s ON s.productkey = p.productkey
       GROUP BY brand
       ORDER BY total_orders DESC

-- count of total customers by country

SELECT country, 
       COUNT(*) AS total_customers 
	   FROM customers
       GROUP BY country
       ORDER BY total_customers DESC

-- Customer Overview

SELECT COUNT(DISTINCT c.customerkey) total_customers, 
       COUNT(DISTINCT s.customerkey) active_customers,
	   COUNT(DISTINCT c.customerkey) - COUNT(DISTINCT s.customerkey) AS non_active_customers
	   FROM customers c
LEFT JOIN sales s ON s.customerkey = c.customerkey

-- count of products by subcategory

SELECT subcategory, 
       COUNT(*) AS total_products 
	   FROM products
       GROUP BY subcategory
       ORDER BY total_products DESC

-- count of products by category

SELECT category, 
       COUNT(*) AS total_products 
	   FROM products
       GROUP BY category
ORDER BY total_products DESC

-- count of stores per country

SELECT country, 
       COUNT(*) AS total_stores 
	   FROM stores
       GROUP BY country



SELECT category, 
       COUNT(DISTINCT productkey) total_products 
	   FROM products
GROUP BY category
ORDER BY total_products DESC


SELECT category, COUNT(DISTINCT s.productkey) FROM sales s
JOIN products p ON p.productkey = s.productkey
GROUP BY category
ORDER BY COUNT(DISTINCT s.productkey)


SELECT gender, 
       COUNT(*) AS total_purchase, 
	   ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS total_revenue 
	   FROM sales s
JOIN customers c ON c.customerkey = s.customerkey
JOIN products p ON p.productkey = s.productkey
GROUP BY gender

SELECT EXTRACT(YEAR FROM open_date) AS open_year, 
       COUNT(*) total_stores FROM stores
GROUP BY open_year
ORDER BY total_stores DESC



/*==============================================================

SECTION 2
Regional Analysis

==============================================================*/

-- Country wise Sales Performance

SELECT country, 
       total_purchase, 
	   total_customers,
	   total_revenue, 
	   median, 
	   ROUND((total_revenue/total_purchase)::NUMERIC,2) AS AOV,
	   ROUND(total_purchase*1.0/total_customers,2) AS AOPC,
	   max_revenue FROM(
SELECT c.country, 
       COUNT(DISTINCT order_number) AS total_purchase,
	   COUNT(DISTINCT c.customerkey) AS total_customers,
	   ROUND(SUM(unit_price_usd * quantity)::NUMERIC,2) AS total_revenue,	   
       ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY (unit_price_usd * quantity))::NUMERIC,2) AS median,
	   ROUND(MAX(unit_price_usd*quantity)::NUMERIC,2) AS max_revenue	   
       FROM sales s
       JOIN products p ON p.productkey = s.productkey
       JOIN customers c ON c.customerkey = s.customerkey
       GROUP BY c.country
       ORDER BY total_revenue DESC
)


-- Active vs Non-active Customers by Country

SELECT
    c.country,
    COUNT(DISTINCT c.customerkey) AS total_customers,
    COUNT(DISTINCT s.customerkey) AS active_customers,
    ROUND(
        COUNT(DISTINCT s.customerkey) * 100.0 /
        COUNT(DISTINCT c.customerkey), 2
    ) AS active_percent,

    COUNT(DISTINCT c.customerkey) - COUNT(DISTINCT s.customerkey) AS non_active_customers,

    ROUND(
        (COUNT(DISTINCT c.customerkey) - COUNT(DISTINCT s.customerkey)) * 100.0 /
        COUNT(DISTINCT c.customerkey), 2
    ) AS non_active_percent

FROM customers c
LEFT JOIN sales s
    ON c.customerkey = s.customerkey

GROUP BY c.country
ORDER BY active_customers DESC;

-- State-wise Sales Performance

	WITH cte AS(
	SELECT country, 
	       state, 
		   order_number,
		   customerkey,
		   COUNT(DISTINCT order_number) AS total_orders, 
		   ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS order_value,
		   ROUND(SUM(unit_cost_usd*quantity)::NUMERIC,2) AS order_cost
		   FROM sales s
	JOIN stores st ON s.storekey = st.storekey
	JOIN products p ON p.productkey = s.productkey
	GROUP BY country,state,order_number,customerkey
	)
	SELECT country, 
	       state,
		   COUNT(DISTINCT customerkey) AS total_customers,
		   ROUND(SUM(order_value)/COUNT(DISTINCT customerkey),2) AS order_per_customer,
		   SUM(total_orders) AS total_orders,
		   SUM(order_value) AS total_revenue,
		   SUM(order_cost) AS total_cost,
		   ROUND(SUM(order_value) - SUM(order_cost),2) AS total_profit,
		   ROUND(AVG(order_value),2) AS AOV,
		   ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY order_value)::NUMERIC,2) AS median_order_value
		   FROM cte
		   GROUP BY country,
		            state
		   ORDER BY country,
		            median_order_value DESC


-- Country-wise Year-over-Year Revenue Growth

 	SELECT country, 
       ROUND(SUM(CASE WHEN years = 2020 THEN total_revenue ELSE 0 END)::NUMERIC,2) AS year_2020,
	   ROUND(SUM(CASE WHEN years = 2019 THEN total_revenue ELSE 0 END)::NUMERIC,2) AS year_2019,
	   
	   ROUND(((SUM(CASE WHEN years = 2020 THEN total_revenue ELSE 0 END)-
	   SUM(CASE WHEN years = 2019 THEN total_revenue ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2019 THEN total_revenue ELSE 0 END))::NUMERIC,2) AS growth_percent_2k19_2k20,
	   
	   ROUND(SUM(CASE WHEN years = 2019 THEN total_revenue ELSE 0 END)::NUMERIC,2) AS year_2019,
	   ROUND(SUM(CASE WHEN years = 2018 THEN total_revenue ELSE 0 END)::NUMERIC,2) AS year_2018,
	   
       ROUND(((SUM(CASE WHEN years = 2019 THEN total_revenue ELSE 0 END)-
	   SUM(CASE WHEN years = 2018 THEN total_revenue ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2018 THEN total_revenue ELSE 0 END))::NUMERIC,2) AS growth_percent_2k18_2k19,
	   
	   ROUND(SUM(CASE WHEN years = 2018 THEN total_revenue ELSE 0 END)::NUMERIC,2) AS year_2018,
	   ROUND(SUM(CASE WHEN years = 2017 THEN total_revenue ELSE 0 END)::NUMERIC,2) AS year_2017,
	   
	   ROUND(((SUM(CASE WHEN years = 2018 THEN total_revenue ELSE 0 END)-
	   SUM(CASE WHEN years = 2017 THEN total_revenue ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2017 THEN total_revenue ELSE 0 END))::NUMERIC,2) AS growth_percent_2k17_2k18,

       ROUND(SUM(CASE WHEN years = 2017 THEN total_revenue ELSE 0 END)::NUMERIC,2) AS year_2017,
	   ROUND(SUM(CASE WHEN years = 2016 THEN total_revenue ELSE 0 END)::NUMERIC,2) AS year_2016,
	   
	   ROUND(((SUM(CASE WHEN years = 2017 THEN total_revenue ELSE 0 END)-
	   SUM(CASE WHEN years = 2016 THEN total_revenue ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2016 THEN total_revenue ELSE 0 END))::NUMERIC,2) AS growth_percent_2k16_2k17
	   
	   FROM(
SELECT s1.country,
       EXTRACT(YEAR FROM order_date) AS years, 
	   SUM(p.unit_price_usd*s.quantity) AS total_revenue
	   FROM sales s
       JOIN stores s1 ON s.storekey = s1.storekey
	   JOIN products p ON p.productkey = s.productkey
       GROUP BY s1.country,
	            years 
       ORDER BY years,
	            s1.country
)
GROUP BY country


SELECT category,
       subcategory,
       brand, 
       COUNT(DISTINCT order_number) AS total_orders,
	   ROUND(SUM(unit_price_usd * quantity)::NUMERIC,2) AS total_revenue,
	   ROUND((SUM(unit_price_usd * quantity)*1.0/COUNT(DISTINCT order_number))::NUMERIC,2) AS AOV
	   FROM products p
	   JOIN sales s ON s.productkey = p.productkey
       GROUP BY category,subcategory,brand
       ORDER BY category,subcategory,brand DESC


-- highest purchase and revenue making countries

-- pin --




/*==============================================================

SECTION 3 
Customer Analysis 

==============================================================*/

-- Customer Activity & Revenue by Age Group

WITH cte AS(
SELECT s.customerkey AS active_customers,
       c.customerkey AS all_customers,
       birthday, 
	   MAX(order_date) AS last_order_date,
	   SUM(unit_price_usd*quantity) AS revenue
	   FROM customers c
LEFT JOIN sales s ON s.customerkey = c.customerkey
LEFT JOIN products p ON p.productkey = s.productkey
GROUP BY s.customerkey,
         c.customerkey, 
         birthday
),
cte2 AS(
SELECT all_customers,
       active_customers, 
	   revenue,
       birthday, 
	   last_order_date, EXTRACT(YEAR FROM AGE((SELECT MAX(order_date) FROM sales),birthday)) AS age FROM cte
)
SELECT CASE
    WHEN age IS NULL THEN 'No Purchase'
    WHEN age < 18 THEN 'under 18'
    WHEN age BETWEEN 18 AND 30 THEN '18-30'
    WHEN age BETWEEN 31 AND 45 THEN '31-45'
    WHEN age BETWEEN 46 AND 60 THEN '46-60'
    ELSE '60+'
END AS customer_group,
			COUNT(all_customers) AS total_customers,
			COUNT(active_customers) AS active_customers,
			COUNT(all_customers) - COUNT(active_customers) AS non_active_customers,
			ROUND((COUNT(all_customers) - COUNT(active_customers))*100.0/COUNT(all_customers),2) AS non_active_percent,
			ROUND(SUM(revenue)::NUMERIC,2) AS total_revenue,
			ROUND((SUM(revenue)*1.0/COUNT(active_customers))::NUMERIC,2) AOV
			FROM cte2
GROUP BY customer_group

-- Age Group Performance Analysis

SELECT CASE
         WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) < 18 THEN 'Under 18'
         WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 18 AND 30 THEN '18-30'
         WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 31 AND 45 THEN '31-45'
         WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 46 AND 60 THEN '46-60'
         ELSE '60+'
       END AS age_group,
	   COUNT(DISTINCT order_number) AS total_orders, 
	   ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS total_revenue,
	   ROUND((SUM(unit_price_usd*quantity)*1.0/COUNT(DISTINCT order_number))::NUMERIC,2) AS AOV
	   FROM sales s
	   JOIN products p ON s.productkey = p.productkey
	   JOIN customers c ON c.customerkey = s.customerkey
	   GROUP BY age_group
	   ORDER BY total_orders



-- Gender-wise Online vs Offline Purchase Analysis

WITH cte AS(
SELECT gender,
       COUNT(CASE WHEN s1.country = 'Online' THEN 1 ELSE NULL END) AS online_purchase,
	   COUNT(CASE WHEN s1.country <> 'Online' THEN 1 ELSE NULL END) AS offline_purchase,
	   COUNT(*) AS total_purchase
FROM sales s
JOIN customers c ON c.customerkey = s.customerkey
JOIN stores s1 ON s.storekey = s1.storekey
GROUP BY gender
)
SELECT gender,
       online_purchase,
	   ROUND(online_purchase*100.0/total_purchase,2) online_purchase_percent,
	   offline_purchase,
	   ROUND(offline_purchase*100.0/total_purchase,2) offline_purchase_percent
FROM cte

-- Gender-wise Category Performance Analysis

-- Which product categories are preferred by male and female customers, and how do they contribute to 
-- revenue and profit within each category?

WITH cte AS(
SELECT gender,
       category,
	   COUNT(*) AS total_purchase,
	   ROUND(SUM(unit_cost_usd*quantity)::NUMERIC,2) AS total_cost,
	   ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS total_revenue,
	   ROUND(SUM(unit_price_usd*quantity)::NUMERIC - SUM(unit_cost_usd*quantity)::NUMERIC,2) AS profit,
	   ROUND(AVG(unit_price_usd*quantity)::NUMERIC,2) AS AOV,
	   ROUND(percentile_cont(0.5) WITHIN GROUP(ORDER BY unit_price_usd*quantity)::NUMERIC,2) AS median_order_value
FROM sales s
JOIN customers c ON c.customerkey = s.customerkey
JOIN stores s1 ON s.storekey = s1.storekey
JOIN products p ON p.productkey = s.productkey
GROUP BY gender,
         category
)
SELECT gender,
       category,
	   total_purchase,
	   ROUND(total_purchase*100.0/SUM(total_purchase) OVER(PARTITION BY category),2) AS purchase_share_within_category,
	   total_revenue,
	   ROUND(total_revenue*100.0/SUM(total_revenue) OVER(PARTITION BY category),2) AS revenue_share_within_category,
	   profit,
	   ROUND(profit*100.0/NULLIF(total_revenue,0),2) profit_percent,
	   ROUND(profit*100.0/SUM(profit) OVER(PARTITION BY category),2) AS profit_share_within_category,
	   AOV,
	   median_order_value
FROM cte
ORDER BY category,
         purchase_share_within_category DESC



-- Age Group vs Product Category Performance

WITH cte AS(
SELECT s.customerkey AS all_customers,
       category,
       birthday, 
	   MAX(order_date) AS last_order_date,
	   SUM(unit_price_usd*quantity)::NUMERIC AS revenue,
	   COUNT(DISTINCT order_number) AS orders
	   FROM sales s
JOIN customers c ON s.customerkey = c.customerkey
JOIN products p ON p.productkey = s.productkey
GROUP BY all_customers,
         category,
         birthday
),
cte2 AS(
SELECT all_customers,
       category,
       birthday, 
	   last_order_date,
	   orders,
	   EXTRACT(YEAR FROM AGE((SELECT MAX(order_date) FROM sales),birthday)) AS age,
	   revenue
	   FROM cte
	   ORDER BY all_customers
)
SELECT CASE
    WHEN age < 18 THEN 'under 18'
    WHEN age BETWEEN 18 AND 30 THEN '18-30'
    WHEN age BETWEEN 31 AND 45 THEN '31-45'
    WHEN age BETWEEN 46 AND 60 THEN '46-60'
    ELSE '60+'
END AS customer_group,
       category,
	   COUNT(DISTINCT all_customers) AS total_customers,
	   SUM(revenue) AS total_revenue,
	   SUM(orders) AS total_orders,
	   ROUND(SUM(revenue)*1.0/COUNT(DISTINCT all_customers),2) AS AOV,
	   ROUND(SUM(orders)*1.0/COUNT(DISTINCT all_customers),2)
			FROM cte2 ct2
GROUP BY customer_group,
         category
ORDER BY category, 
         customer_group DESC

-- Age Group vs Country Performance

WITH cte AS(
SELECT s.customerkey AS all_customers,
       country,
       birthday, 
	   MAX(order_date) AS last_order_date,
	   SUM(unit_price_usd*quantity)::NUMERIC AS revenue,
	   COUNT(DISTINCT order_number) AS orders
	   FROM sales s
JOIN customers c ON s.customerkey = c.customerkey
JOIN products p ON p.productkey = s.productkey
GROUP BY all_customers,
         country,
         birthday
),
cte2 AS(
SELECT all_customers,
       country,
       birthday, 
	   orders,
	   last_order_date, 
	   EXTRACT(YEAR FROM AGE((SELECT MAX(order_date) FROM sales),birthday)) AS age,
	   revenue
	   FROM cte
	   ORDER BY all_customers
)
SELECT CASE
    WHEN age < 18 THEN 'under 18'
    WHEN age BETWEEN 18 AND 30 THEN '18-30'
    WHEN age BETWEEN 31 AND 45 THEN '31-45'
    WHEN age BETWEEN 46 AND 60 THEN '46-60'
    ELSE '60+'
END AS customer_group,
       country,
	   COUNT(DISTINCT all_customers) AS total_customers,
	   SUM(revenue) AS total_revenue,
	   SUM(orders) AS total_orders,
	   ROUND(SUM(revenue)*1.0/COUNT(DISTINCT all_customers),2) AS revenue_per_customer,
	   ROUND(SUM(revenue)*1.0/SUM(orders),2) AS AOV,
	   SUM(COUNT(DISTINCT all_customers)) OVER(PARTITION BY country) AS total_customers_base,
	   ROUND(COUNT(DISTINCT all_customers)*100.0/SUM(COUNT(DISTINCT all_customers)) OVER(PARTITION BY country),2) AS customers_distribution,
	   ROUND(SUM(orders)*1.0/COUNT(DISTINCT all_customers),2) AS AOPC
	   FROM cte2 ct2
GROUP BY customer_group,
         country
ORDER BY country, 
         customer_group DESC

-- Age Group-wise Online vs Offline Purchase Analysis

WITH cte AS(
SELECT CASE
    WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) < 18 THEN 'Under 18'
    WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 18 AND 30 THEN '18-30'
    WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 31 AND 45 THEN '31-45'
    WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 46 AND 60 THEN '46-60'
    ELSE '60+'
END AS age_group, 
       COUNT(DISTINCT order_number) FILTER(WHERE s1.country = 'Online') AS online_purchase,
	   COUNT(DISTINCT order_number) FILTER(WHERE s1.country <> 'Online') AS offline_purchase,
	   COUNT(DISTINCT order_number) AS total_purchase,
	   ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS total_revenue,
	   ROUND(SUM(unit_cost_usd*quantity)::NUMERIC,2) AS total_cost
FROM sales s
JOIN customers c ON c.customerkey = s.customerkey
JOIN stores s1 ON s.storekey = s1.storekey
JOIN products p ON p.productkey = s.productkey
GROUP BY age_group
)
SELECT age_group,
       online_purchase,
	   ROUND(online_purchase*100.0/total_purchase,2) online_purchase_percent,
	   offline_purchase,
	   ROUND(offline_purchase*100.0/total_purchase,2) offline_purchase_percent,
	   total_revenue,
	   total_cost,
	   total_revenue - total_cost AS total_profit,
	   ROUND(((total_revenue - total_cost)*100.0/total_revenue)::NUMERIC,2) AS profit_percent
FROM cte

-- Age Group-wise Category Preference Analysis

WITH cte AS(
SELECT CASE
    WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) < 18 THEN 'Under 18'
    WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 18 AND 30 THEN '18-30'
    WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 31 AND 45 THEN '31-45'
    WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 46 AND 60 THEN '46-60'
    ELSE '60+'
END AS age_group,
    category,
	COUNT(DISTINCT order_number) AS total_purchase,
	ROUND(SUM(unit_cost_usd*quantity)::NUMERIC,2) AS total_cost,
	ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS total_revenue,
	ROUND(AVG(unit_price_usd*quantity)::NUMERIC,2) AS AOV,
	ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) - ROUND(SUM(unit_cost_usd*quantity)::NUMERIC,2) AS profit,
	COUNT(DISTINCT c.customerkey) AS customer_count
FROM sales s
JOIN customers c ON c.customerkey = s.customerkey
JOIN stores s1 ON s.storekey = s1.storekey
JOIN products p ON p.productkey = s.productkey
GROUP BY age_group,
         category
ORDER BY age_group,
         total_purchase DESC
)
SELECT age_group,
       category,
	   total_purchase,
	   ROUND(total_purchase*100.0/SUM(total_purchase) OVER(PARTITION BY category),2) AS customer_preference,
	   AOV,
	   total_revenue,
	   ROUND(total_revenue*100.0/SUM(total_revenue) OVER(PARTITION BY category),2) AS revenue_contribution,
	   profit,
	   ROUND(profit*100.0/SUM(profit) OVER(PARTITION BY category),2) as profit_contribution,
	   ROUND(profit*100.0/total_revenue,2) AS profit_percent,
	   customer_count,
	   ROUND(total_purchase*1.0/customer_count,2) AS average_purchase_per_customer
	   FROM cte
	   ORDER BY age_group,customer_preference DESC

-- Age Group-wise Subcategory Preference Analysis

WITH cte AS(
SELECT CASE
    WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) < 18 THEN 'Under 18'
    WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 18 AND 30 THEN '18-30'
    WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 31 AND 45 THEN '31-45'
    WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 46 AND 60 THEN '46-60'
    ELSE '60+'
END AS age_group,
    subcategory,
	COUNT(DISTINCT order_number) AS total_purchase,
	ROUND(SUM(unit_cost_usd*quantity)::NUMERIC,2) AS total_cost,
	ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS total_revenue,
	ROUND(AVG(unit_price_usd*quantity)::NUMERIC,2) AS AOV,
	ROUND(SUM(unit_price_usd*quantity)::NUMERIC - SUM(unit_cost_usd*quantity)::NUMERIC,2) AS profit,
	COUNT(DISTINCT c.customerkey) AS customer_count
FROM sales s
JOIN customers c ON c.customerkey = s.customerkey
JOIN stores s1 ON s.storekey = s1.storekey
JOIN products p ON p.productkey = s.productkey
GROUP BY age_group,
         subcategory
)
SELECT age_group,
       subcategory,
	   total_purchase,
	   ROUND(total_purchase*100.0/SUM(total_purchase) OVER(PARTITION BY subcategory),2) AS purchase_share_within_subcategory,
	   AOV,
	   total_revenue,
	   ROUND(total_revenue*100.0/SUM(total_revenue) OVER(PARTITION BY subcategory),2) AS revenue_share_within_subcategory,
	   profit,
	   ROUND(profit*100.0/SUM(profit) OVER(PARTITION BY subcategory),2) as profit_share_within_subcategory,
	   ROUND(profit*100.0/total_revenue,2) AS profit_percent,
	   customer_count,
	   ROUND(total_purchase*1.0/customer_count,2) AS average_purchase_per_customer
	   FROM cte
	   ORDER BY subcategory,purchase_share_within_subcategory DESC

-- Country-wise Repeat Customer Analysis

WITH total_orders AS( 
SELECT c.customerkey AS customer_id, 
       c.country, 
	   COUNT(DISTINCT order_number) AS total_orders 
	   FROM sales s
JOIN customers c ON c.customerkey = s.customerkey
GROUP BY c.customerkey,
         c.country
ORDER BY total_orders DESC
)
SELECT country, 
	   SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
	   ROUND(AVG(total_orders),2) AS avg_order_repeat_customers,
	   COUNT(*) AS total_customers,
	   ROUND(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS repeat_customers_percent
	   FROM total_orders
	   GROUP BY country
	   ORDER BY total_orders DESC

-- Age Group-wise Repeat Customer Analysis

WITH total_orders AS(
SELECT c.customerkey,
       CASE
       WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) < 18 THEN 'Under 18'
       WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 18 AND 30 THEN '18-30'
       WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 31 AND 45 THEN '31-45'
       WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 46 AND 60 THEN '46-60'
       ELSE '60+'
       END AS age_group,
       COUNT(DISTINCT order_number) AS total_orders
       FROM sales s
	   JOIN customers c ON c.customerkey = s.customerkey
	   GROUP BY c.customerkey,
	            age_group
)
SELECT age_group, 
	   SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
	   ROUND(AVG(total_orders),2) AS avg_orders_per_customer,
	   COUNT(*) AS total_customers,
	   ROUND(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS repeat_customers_percent
	   FROM total_orders
	   GROUP BY age_group
	   ORDER BY age_group

-- Customer Repeat Purchase Rate by Age Group Across Countries

WITH total_orders AS(
SELECT c.country,
       c.customerkey,
       CASE
       WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) < 18 THEN 'Under 18'
       WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 18 AND 30 THEN '18-30'
       WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 31 AND 45 THEN '31-45'
       WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 46 AND 60 THEN '46-60'
       ELSE '60+'
       END AS age_group,
       COUNT(DISTINCT order_number) AS total_orders
       FROM sales s
	   JOIN customers c ON c.customerkey = s.customerkey
	   GROUP BY c.country,
	            c.customerkey,
	            age_group
)
SELECT country,
       age_group, 
	   SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
	   ROUND(AVG(total_orders),2) AS avg_order_repeat_customers,
	   COUNT(*) AS total_customers,
	   ROUND(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS repeat_customers_percent
	   FROM total_orders
	   GROUP BY country,age_group
	   ORDER BY country,age_group

-- Repeat Customer Analysis by Gender

WITH total_orders AS( 
SELECT c.customerkey AS customer_id, 
       c.gender, 
	   COUNT(DISTINCT order_number) AS total_orders 
	   FROM sales s
JOIN customers c ON c.customerkey = s.customerkey
GROUP BY c.customerkey,
         c.gender
ORDER BY total_orders DESC
)
SELECT gender, 
	   SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
	   ROUND(AVG(total_orders),2) AS avg_order_repeat_customers,
	   COUNT(*) AS total_customers,
	   ROUND(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS repeat_customers_percent
	   FROM total_orders
	   GROUP BY gender

-- Category-wise Customer Loyalty Analysis

WITH base_table AS(
SELECT c.customerkey, 
       p.category, 
	   EXTRACT(YEAR FROM order_date) AS years, 
	   COUNT(DISTINCT order_number) AS total_orders,
	   SUM(unit_price_usd*quantity) AS total_revenue 
	   FROM sales s
JOIN customers c ON c.customerkey = s.customerkey
JOIN products p ON p.productkey = s.productkey
GROUP BY c.customerkey,p.category,years
)
SELECT category,
       COUNT(*) AS total_customers,
	   SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
	   ROUND(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS repeat_customers,
	   ROUND(SUM(total_revenue)::NUMERIC,2) AS total_revenue,
	   ROUND(SUM(total_revenue) FILTER(WHERE total_orders > 1)::NUMERIC,2) AS repeat_customer_revenue,
	   ROUND((SUM(total_revenue) FILTER(WHERE total_orders > 1)*100.0/SUM(total_revenue))::NUMERIC,2) AS repeat_customer_revenue_percent
	   FROM base_table
       GROUP BY category



-- Annual Customer Segmentation (One-time, Occasional, Loyal & VIP)

WITH customer_orders AS (
    SELECT
	    EXTRACT(YEAR FROM order_date) AS years,
        customerkey,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(s.quantity*p.unit_price_usd) AS revenue
    FROM sales s
	JOIN products p ON p.productkey = s.productkey
    GROUP BY customerkey,years
)
SELECT years,
       CASE WHEN total_orders = 1 THEN 'One-time'
            WHEN total_orders BETWEEN 2 AND 5  THEN 'Occasinal'
			WHEN total_orders BETWEEN 6 AND 10 THEN 'Loyal'
			ELSE 'VIP'
			END AS customer_groups,
			COUNT(*) AS total_customers,
			ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(),2) AS customers,
			ROUND(SUM(revenue)::NUMERIC,2) AS revenue_contribution,
			ROUND(SUM(revenue)::NUMERIC*100.0/SUM(SUM(revenue)) OVER()::NUMERIC,2) AS total_revenue,
			ROUND(SUM(revenue)::NUMERIC/SUM(total_orders),2) AS Average_order_value,
			ROUND(SUM(revenue)::NUMERIC/COUNT(*),2) AS revenue_per_customer	
			FROM customer_orders
			GROUP BY customer_groups,
			         years
			ORDER BY years,
			         customer_groups


-- Year-wise New vs Existing Customer Retention Analysis

WITH first_purchase AS(

SELECT customerkey, 

       MIN(order_date) AS first_purchase_date 
	   
	   FROM sales s 
	   
GROUP BY customerkey

),

total_orders AS( 

SELECT s.customerkey AS customer_id, 

       CASE WHEN EXTRACT(YEAR FROM order_date) = EXTRACT(YEAR FROM first_purchase_date) THEN 'New Customers' ELSE 'Old Customers' END AS customer_groups,

       EXTRACT(YEAR FROM order_date) AS years, 
	   
	   COUNT(DISTINCT order_number) AS total_orders,
	   
	   SUM(unit_price_usd*quantity) AS total_revenue
	   
	   FROM sales s
	   
JOIN products p ON s.productkey = p.productkey

JOIN first_purchase fp ON s.customerkey = fp.customerkey

GROUP BY s.customerkey,

         years,

        customer_groups

)


SELECT customer_groups,
       
	   years, 

       COUNT(*) AS total_customers,

	   ROUND(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS repeat_customers_percent,

       SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,

	   ROUND(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)*100.0/SUM(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)) OVER(PARTITION BY years),2) AS repeat_shares,  
	   
	   ROUND(SUM(CASE WHEN total_orders > 1 THEN total_revenue ELSE 0 END)::NUMERIC,2) AS repeat_customers_revenue,

	   ROUND(SUM(CASE WHEN total_orders > 1 THEN total_orders ELSE 0 END)/SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END),2) AS repeat_orders,
	   
	   ROUND((SUM(CASE WHEN total_orders > 1 THEN total_revenue ELSE 0 END)/SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END))::NUMERIC,2) Average_revenue_per_repeat_customer,
	   
	   ROUND((SUM(CASE WHEN total_orders > 1 THEN total_revenue ELSE 0 END)/SUM(CASE WHEN total_orders > 1 THEN total_orders ELSE 0 END))::NUMERIC,2) AOV_repeat_customers,
	   
	   ROUND(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)*100.0/SUM(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)) OVER(),2) AS rc_distribution,
	   
	   SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END) AS one_time_customers,
	   
	   ROUND(SUM(CASE WHEN total_orders = 1 THEN total_revenue ELSE 0 END)::NUMERIC,2) AS one_time_customer_revenue,

       ROUND((SUM(CASE WHEN total_orders = 1 THEN total_revenue ELSE 0 END)/SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END))::NUMERIC,2) AS OneTime_customer_purchase,
	   	   
	   ROUND(SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END)*100.0/SUM(SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END)) OVER(),2) AS otc_distribution,
	   
	   ROUND(AVG(total_orders),2) AS avg_order_repeat_customers
	   	   	   
	   FROM total_orders
	   
	   GROUP BY customer_groups,
	     
	            years

	   ORDER BY years,
	   
	            customer_groups



-- Year-wise Customer Behaviour Across Sales Channels

WITH total_orders AS(

SELECT CASE WHEN country = 'Online' THEN 'Online store'
       
       ELSE 'Offline store'

       END AS customer_groups,
       
	   s.customerkey AS customer_id, 

       EXTRACT(YEAR FROM order_date) AS years, 
	   
	   COUNT(DISTINCT order_number) AS total_orders,
	   
	   SUM(unit_price_usd*quantity) AS total_revenue
	   
	   FROM sales s
	   
JOIN products p ON s.productkey = p.productkey

JOIN stores st ON st.storekey = s.storekey

GROUP BY customer_groups,

         s.customerkey,

         years


)

SELECT customer_groups,
       
	   years, 

  	   COUNT(DISTINCT customer_id) AS total_customers,

       ROUND(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)*100.0/COUNT(*),2) repeat_customers_percent,

       SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
	   
	   ROUND(SUM(CASE WHEN total_orders > 1 THEN total_revenue ELSE 0 END)::NUMERIC,2) AS repeat_customers_revenue,

	   ROUND(SUM(CASE WHEN total_orders > 1 THEN total_orders ELSE 0 END)/NULLIF(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END),0),2) AS repeat_orders,
	   
	   ROUND((SUM(CASE WHEN total_orders > 1 THEN total_revenue ELSE 0 END)/NULLIF(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END),0))::NUMERIC,2) Average_customer_purchase,
	   
	   ROUND((SUM(CASE WHEN total_orders > 1 THEN total_revenue ELSE 0 END)/NULLIF(SUM(CASE WHEN total_orders > 1 THEN total_orders ELSE 0 END),0))::NUMERIC,2) AOV_repeat_customers,
	   
	   ROUND(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)*100.0/NULLIF(SUM(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)) OVER(),0),2) AS rc_distribution,

	   ROUND(SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS one_time_customers_percent,
	   
	   SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END) AS one_time_customers,
	   
	   ROUND(SUM(CASE WHEN total_orders = 1 THEN total_revenue ELSE 0 END)::NUMERIC,2) AS one_time_customer_revenue,

       ROUND((SUM(CASE WHEN total_orders = 1 THEN total_revenue ELSE 0 END)/NULLIF(SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END),0))::NUMERIC,2) AS OneTime_customer_purchase,
	   	   
	   ROUND(SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END)*100.0/NULLIF(SUM(SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END)) OVER(),0),2) AS otc_distribution,
	   
	   ROUND(AVG(total_orders),2) AS avg_order_repeat_customers,
	   
	   ROUND(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS repeat_customers_percent
	   
	   FROM total_orders
	   
	   GROUP BY years,

				customer_groups
	   
	   ORDER BY years


-- New vs Existing Customer Analysis

WITH first_purchase AS(
SELECT customerkey, 
       MIN(EXTRACT(YEAR FROM order_date)) AS first_order 
	   FROM sales
GROUP BY customerkey
),
customer_orders AS(
SELECT customerkey, 
       EXTRACT(YEAR FROM order_date) AS order_year,
	   COUNT(DISTINCT order_number) AS total_orders,
	   SUM(unit_price_usd*quantity) AS total_revenue
	   FROM sales s
	   JOIN products p ON p.productkey = s.productkey
	   GROUP BY customerkey,order_year
),
final_table AS(
SELECT fp.customerkey,
       fp.first_order,
	   co.order_year,
	   CASE WHEN fp.first_order = co.order_year THEN 'new customers'
	   ELSE 'existing customers' END AS customer_groups,
	   co.total_orders,
	   total_revenue
	   FROM first_purchase fp 
	   JOIN customer_orders co ON fp.customerkey = co.customerkey
	   ORDER BY fp.customerkey
)
SELECT order_year,
       customer_groups, 
	   COUNT(*) AS total_customers, 
       SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
	   ROUND(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS repeat_customers_percent,
	   ROUND(SUM(CASE WHEN total_orders > 1 THEN total_revenue ELSE 0 END)::NUMERIC,2) AS revenue_contribution,
	   ROUND(SUM(CASE WHEN total_orders > 1 THEN total_revenue ELSE 0 END)::NUMERIC*100.0/SUM(total_revenue)::NUMERIC,2) AS revenue_contribution_percent 
       FROM final_table
       GROUP BY order_year, 
	            customer_groups
	   ORDER BY order_year,
	            customer_groups


-- Country-wise Year-over-Year Purchase Growth.sql

 	SELECT country, 
       SUM(CASE WHEN years = 2020 THEN total_purchase ELSE 0 END) AS year_2020,
	   SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END) AS year_2019,
	   
	   ROUND((SUM(CASE WHEN years = 2020 THEN total_purchase ELSE 0 END)-
	   SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END),2) AS growth_percent_2k19_2k20,
	   
	   SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END) AS year_2019,
	   SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END) AS year_2018,
	   
       ROUND((SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END)-
	   SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END),2) AS growth_percent_2k18_2k19,
	   
	   SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END) AS year_2018,
	   SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END) AS year_2017,
	   
	   ROUND((SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END)-
	   SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END),2) AS growth_percent_2k17_2k18,

       SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END) AS year_2017,
	   SUM(CASE WHEN years = 2016 THEN total_purchase ELSE 0 END) AS year_2016,
	   
	   ROUND((SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END)-
	   SUM(CASE WHEN years = 2016 THEN total_purchase ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2016 THEN total_purchase ELSE 0 END),2) AS growth_percent_2k16_2k17
	   
	   FROM(
SELECT s1.country,
       EXTRACT(YEAR FROM order_date) AS years, 
	   COUNT(DISTINCT order_number) AS total_purchase 
	   FROM sales s
       JOIN stores s1 ON s.storekey = s1.storekey
       GROUP BY s1.country,
	            years 
)
GROUP BY country


/*==============================================================

Section 4
Sales Channel Analysis

==============================================================*/

-- Overall Sales Channel Distribution

SELECT CASE WHEN country = 'Online' THEN 'online Orders'
       ELSE 'Offline Orders' END AS mode_of_purchase,
	   COUNT(DISTINCT order_number),
	   ROUND(COUNT(DISTINCT order_number)*100.0/SUM(COUNT(DISTINCT order_number)) OVER(),2) FROM sales s
	   JOIN stores s1 ON s.storekey = s1.storekey
	   GROUP BY mode_of_purchase


-- total purchase and total revenue by mode of purchase 

SELECT country,
       mode_of_purchase,
	   total_orders,
	   active_stores,
	   total_stores,
	   ROUND(total_orders*1.0/total_customers,2) AOPC,
	   order_contribution_percent,
	   total_revenue,
	   revenue_percent
	   FROM(
SELECT country,
       CASE WHEN country = 'Online' THEN 'Online' ELSE 'Offline' END AS mode_of_purchase,
       COUNT(DISTINCT order_number) total_orders,
	   COUNT(DISTINCT s.storekey) AS active_stores,
	   COUNT(DISTINCT st.storekey) AS total_stores,
	   COUNT(DISTINCT customerkey) AS total_customers,
	   ROUND(COUNT(DISTINCT order_number)*100.0/SUM(COUNT(DISTINCT order_number)) OVER(),2) AS order_contribution_percent,
	   ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS total_revenue,
	   COALESCE(ROUND(SUM(unit_price_usd*quantity)::NUMERIC*100.0/SUM(SUM(unit_price_usd*quantity)) OVER()::NUMERIC,2),0) AS revenue_percent
	   FROM stores st
	   LEFT JOIN sales s ON s.storekey = st.storekey
	   LEFT JOIN products p ON p.productkey = s.productkey
	   GROUP BY mode_of_purchase,country
)
ORDER BY total_revenue DESC

-- Country-wise Online vs Offline Sales Performance

SELECT
    c.country,
    CASE
        WHEN st.country = 'Online' THEN 'Online'
        ELSE 'Offline'
    END AS mode_of_purchase,

    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT c.customerkey) AS total_customers,

    ROUND(SUM(unit_price_usd * quantity)::NUMERIC, 2) AS total_revenue,

    ROUND(
        COUNT(DISTINCT order_number) * 100.0 /
        SUM(COUNT(DISTINCT order_number)) OVER (PARTITION BY c.country),
        2
    ) AS purchase_mode_distribution,

    ROUND(
        COUNT(DISTINCT order_number) * 1.0 /
        COUNT(DISTINCT c.customerkey),
        2
    ) AS AOPC

FROM sales s
JOIN customers c
    ON c.customerkey = s.customerkey
JOIN stores st
    ON st.storekey = s.storekey
JOIN products p
    ON p.productkey = s.productkey

GROUP BY
    c.country,
    mode_of_purchase

ORDER BY
    c.country,
    mode_of_purchase;


-- Category-wise Online vs Offline Sales Performance

WITH cte AS(
SELECT category,
       CASE WHEN country = 'Online' THEN 'Online' ELSE 'Offline' END AS mode_of_purchase,
       COUNT(DISTINCT order_number) total_orders_placed,
	   ROUND(COUNT(DISTINCT order_number)*100.0/SUM(COUNT(DISTINCT order_number)) OVER(),2) AS orders_percent,
	   ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS total_revenue,
  	   ROUND(SUM(unit_cost_usd*quantity)::NUMERIC,2) AS total_cost,
	   ROUND(SUM(unit_price_usd*quantity)::NUMERIC - SUM(unit_cost_usd*quantity)::NUMERIC,2) AS total_profit,
	   ROUND(SUM(unit_price_usd*quantity)::NUMERIC*100.0/SUM(SUM(unit_price_usd*quantity)) OVER()::NUMERIC,2) AS revenue_percent,
	   percentile_cont(0.5) WITHIN GROUP(ORDER BY (unit_price_usd*quantity)) AS median_order_value,
       ROUND(AVG(unit_price_usd*quantity)::NUMERIC,2) AOV
       FROM stores st
	   LEFT JOIN sales s ON s.storekey = st.storekey
	   LEFT JOIN products p ON p.productkey = s.productkey
	   GROUP BY mode_of_purchase,
	            category
	   ORDER BY category
)
SELECT category,
       mode_of_purchase,
	   total_orders_placed,
	   orders_percent,
	   total_revenue,
	   total_cost,
	   total_profit,
	   ROUND(total_profit*100.0/total_revenue,2) AS profit_percent,
	   revenue_percent,
	   median_order_value,
	   AOV 
	   FROM cte 

-- Category-wise Purchase Behavior by Sales Channel

WITH cte AS(
SELECT category,
       CASE WHEN country = 'Online' THEN 'Online' ELSE 'Offline' END AS mode_of_purchase,
       COUNT(*) total_purchase,
	   ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS total_revenue,
	   ROUND(percentile_cont(0.5) WITHIN GROUP(ORDER BY (unit_price_usd*quantity))::NUMERIC,2) AS median,
       ROUND(AVG(unit_price_usd*quantity)::NUMERIC,2) AOV
       FROM sales s
	   JOIN stores s1 ON s.storekey = s1.storekey
	   JOIN products p ON p.productkey = s.productkey
	   GROUP BY mode_of_purchase,
	            category
	   ORDER BY category
)
SELECT category, 
       mode_of_purchase, 
	   total_purchase, 
	   ROUND(total_purchase*100.0/SUM(total_purchase) OVER(PARTITION BY mode_of_purchase),2) AS purchase_percent,
	   total_revenue,
	   ROUND(total_revenue*100.0/SUM(total_revenue) OVER(PARTITION BY mode_of_purchase),2) AS revenue_percent,
	   median,
	   aov
	   FROM cte
	   ORDER BY mode_of_purchase,category


-- Year-wise Category Sales Trend

SELECT EXTRACT(YEAR FROM order_date) AS years,
       category,
       ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS total_revenue,
       COUNT(DISTINCT order_number) AS total_orders,
       ROUND(SUM(unit_price_usd*quantity)::NUMERIC/COUNT(DISTINCT order_number),2) AS average_order_value 
	   FROM sales s
	JOIN products p ON p.productkey = s.productkey
	GROUP BY years,
	         category
	ORDER BY years,
	         category

-- Sales Channel Performance Trend

WITH cte AS(
SELECT EXTRACT(YEAR FROM order_date) years, 
       COUNT(DISTINCT order_number) FILTER(WHERE country = 'Online') AS online_orders,
       COUNT(DISTINCT order_number) FILTER(WHERE country <> 'Online') AS offline_orders,
	   COUNT(DISTINCT order_number) AS total_orders,
	   ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS total_revenue,
	   ROUND(SUM(unit_cost_usd*quantity)::NUMERIC,2) AS total_cost 
	   FROM sales s
JOIN stores s1 ON s.storekey = s1.storekey
JOIN products p ON p.productkey = s.productkey
GROUP BY years
ORDER BY years
)
SELECT years,
       total_orders,
       online_orders,
	   ROUND(online_orders*100.0/total_orders,2) AS online_orders_percent,
	   offline_orders,
	   ROUND(offline_orders*100.0/total_orders) AS offline_orders_percent,
	   total_revenue,
	   total_cost,
	   total_revenue - total_cost AS total_profit,
	   ROUND((total_revenue - total_cost)*100.0/total_revenue,2) AS profit_percent
FROM cte

-- Monthly Order Trend Analysis

WITH cte AS(
SELECT DATE_TRUNC('MONTH',order_date) AS date_of_order, 
       COUNT(*) AS total_orders 
	   FROM sales
       GROUP BY date_of_order
       ORDER BY date_of_order
),
cte2 AS(
SELECT date_of_order, 
       total_orders, 
	   ROUND(total_orders*100.0/SUM(total_orders) OVER(PARTITION BY DATE_TRUNC('year',date_of_order)),2) AS monthly_order_percent,
	   LAG(total_orders) OVER(PARTITION BY EXTRACT(year FROM date_of_order) ORDER BY date_of_order) AS prev_month_orders,
	   total_orders - LAG(total_orders) OVER(PARTITION BY EXTRACT(year FROM date_of_order) ORDER BY date_of_order) AS tracking_order_growth
	   FROM cte
)
SELECT date_of_order,
       total_orders,
	   monthly_order_percent,
	   prev_month_orders,
	   tracking_order_growth,
	   ROUND(tracking_order_growth*100.0/NULLIF(prev_month_orders,0),2) AS growth_percent
FROM cte2
ORDER BY date_of_order



-- Monthly Online vs Offline Order Trend

WITH cte AS(
SELECT DATE_TRUNC('MONTH',order_date)::DATE AS order_month, 
       COUNT(DISTINCT order_number) FILTER(WHERE country = 'Online') AS online_orders,
       COUNT(DISTINCT order_number) FILTER(WHERE country <> 'Online') AS offline_orders,
       COUNT(DISTINCT order_number) AS total_orders FROM sales s
JOIN stores s1 ON s.storekey = s1.storekey
GROUP BY order_month
)
SELECT order_month,
       total_orders,
       online_orders,
	   COALESCE(ROUND(online_orders*100.0/NULLIF(SUM(online_orders) OVER(PARTITION BY EXTRACT(YEAR FROM order_month)),0),2),0) AS online_order_contribution,
	   COALESCE(ROUND(online_orders*100.0/total_orders,2),0) online_distribution_percent,
	   offline_orders,
	   COALESCE(ROUND(offline_orders*100.0/NULLIF(SUM(offline_orders) OVER(PARTITION BY EXTRACT(YEAR FROM order_month)),0),2),0) AS offline_order_contribution,
	   COALESCE(ROUND(offline_orders*100.0/total_orders,2),0) AS offline_distribution_percent
FROM cte



/*==============================================================

Section 5
Product Analysis

==============================================================*/

-- Revenue per Customer by Category

SELECT category, 
       COUNT(DISTINCT order_number) AS total_orders,
       ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS total_revenue, 
	   ROUND(SUM(unit_cost_usd*quantity)::NUMERIC,2) AS total_cost, 
	   ROUND(SUM(unit_price_usd*quantity)::NUMERIC - SUM(unit_cost_usd*quantity)::NUMERIC,2) AS total_profit,
	   ROUND((SUM(unit_price_usd*quantity)*1.0/COUNT(DISTINCT customerkey))::NUMERIC,2) AS aov,
	   COUNT(DISTINCT customerkey) AS total_customers,
       ROUND(SUM(unit_price_usd*quantity)::NUMERIC*1.0/COUNT(DISTINCT customerkey),2) AS revenue_per_customer,
	   ROUND(COUNT(DISTINCT order_number)*1.0/COUNT(DISTINCT customerkey),2) AS order_per_customer
	   FROM sales s
JOIN products p ON p.productkey = s.productkey
GROUP BY category
ORDER BY revenue_per_customer DESC;

-- Category & Subcategory Revenue Analysis

SELECT category, 
       subcategory, 
	   ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS tota_revenue, 
	   ROUND((percentile_cont(0.5) WITHIN GROUP(ORDER BY (unit_price_usd*quantity)))::NUMERIC,2) AS median_order_value,
       ROUND((SUM(unit_price_usd*quantity)/COUNT(DISTINCT order_number))::NUMERIC,2) AS avg_order_value
FROM sales s
JOIN products p 
ON p.productkey = s.productkey
GROUP BY category, subcategory



-- Category Profitability Analysis

SELECT category, 
       total_revenue, 
	   total_cost, 
	   total_profit, 
	   ROUND(total_profit::NUMERIC*100.0/total_revenue,2) AS profit_percent
FROM(
SELECT category, 
       ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS total_revenue, 
	   ROUND(SUM(unit_cost_usd*quantity)::NUMERIC,2) AS total_cost,
       ROUND((SUM(unit_price_usd*quantity) - SUM(unit_cost_usd*quantity))::NUMERIC,2) AS total_profit 
	   FROM sales s
JOIN products p ON p.productkey = s.productkey
GROUP BY category
)


-- Category & Subcategory Performance Analysis

SELECT category, 
       subcategory, 
	   COUNT(DISTINCT s.order_number) AS total_orders, 
	   COUNT(DISTINCT s.productkey) sold_products,
	   ROUND(COUNT(DISTINCT s.order_number)*1.0/COUNT(DISTINCT p.productkey),2) AS order_per_product,
	   ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS total_revenue,
	   ROUND((SUM(unit_price_usd*quantity) - SUM(unit_cost_usd*quantity))::NUMERIC,2) AS total_profit,
	   ROUND(((SUM(unit_price_usd*quantity) - SUM(unit_cost_usd*quantity))*100.0/SUM(unit_price_usd*quantity))::NUMERIC,2) AS profit_contribution
	   FROM products p
LEFT JOIN sales s ON s.productkey = p.productkey
GROUP BY category,
         subcategory
ORDER BY category, 
         total_orders DESC

			 
-- Subcategory-wise Online vs Offline Purchase Analysis

SELECT category,
       subcategory,
       CASE WHEN country = 'Online' THEN 'Online' ELSE 'Offline' END AS mode_of_purchase,
       COUNT(DISTINCT order_number) total_purchase,
	   ROUND(COUNT(DISTINCT order_number)*100.0/SUM(COUNT(DISTINCT order_number)) OVER(PARTITION BY category),2) AS purchase_percent,
	   ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS total_revenue,
	   ROUND(SUM(unit_price_usd*quantity)::NUMERIC*100.0/SUM(SUM(unit_price_usd*quantity)) OVER(PARTITION BY category)::NUMERIC,2) AS revenue_percent,
	   ROUND(percentile_cont(0.5) WITHIN GROUP(ORDER BY (unit_price_usd*quantity))::NUMERIC,2) AS median,
       ROUND(AVG(unit_price_usd*quantity)::NUMERIC,2) AOV
       FROM sales s
	   JOIN stores s1 ON s.storekey = s1.storekey
	   JOIN products p ON p.productkey = s.productkey
	   GROUP BY mode_of_purchase,
	            category,
				subcategory
	   ORDER BY category


-- Year-wise Category & Subcategory Performance

SELECT EXTRACT(YEAR FROM order_date) AS order_year,
       category, 
       subcategory, 
	   COUNT(DISTINCT order_number) AS total_orders, 
	   ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS total_revenue,
       ROUND(SUM(unit_cost_usd*quantity)::NUMERIC,2) AS total_cost, 
	   ROUND((SUM(unit_price_usd*quantity) - SUM(unit_cost_usd*quantity))::NUMERIC,2) AS total_profit,
	   ROUND((SUM(unit_price_usd*quantity) - SUM(unit_cost_usd*quantity))::NUMERIC*100.0/NULLIF(SUM(unit_price_usd*quantity)::NUMERIC,0),2) AS profit_percent,
	   ROUND(SUM(unit_price_usd*quantity)::NUMERIC*1.0/COUNT(DISTINCT order_number),2) AS AOV
FROM sales s 
JOIN products p ON p.productkey = s.productkey
GROUP BY order_year, 
         category, 
		 subcategory

-- Country-wise Category Performance Analysis

SELECT country, 
       category, 
	   COUNT(DISTINCT order_number) AS total_purchase,
	   ROUND(COUNT(DISTINCT order_number)*100.0/SUM(COUNT(DISTINCT order_number)) OVER(PARTITION BY category),2) AS purchase_percent_category,
	   ROUND(COUNT(DISTINCT order_number)*100.0/SUM(COUNT(DISTINCT order_number)) OVER(PARTITION BY country),2) AS purchase_percent,
	   ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS total_revenue,
	   ROUND(SUM(unit_price_usd*quantity)::NUMERIC*100.0/SUM(SUM(unit_price_usd*quantity)) OVER(PARTITION BY category)::NUMERIC,2) AS revenue_contribution,
	   ROUND((SUM(unit_price_usd*quantity)/COUNT(DISTINCT order_number))::NUMERIC,2) AS category_AOV,
	   ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY unit_price_usd*quantity)::NUMERIC,2) AS MOV
	   FROM sales s 
JOIN stores s1 ON s.storekey = s1.storekey
JOIN products p ON p.productkey = s.productkey
GROUP BY country,
         category
ORDER BY category,    
         purchase_percent DESC


-- Category Year-over-Year Performance Analysis

 	SELECT category, 
       SUM(CASE WHEN years = 2020 THEN total_purchase ELSE 0 END) AS year_2020,
	   SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END) AS year_2019,
	   
	   ROUND((SUM(CASE WHEN years = 2020 THEN total_purchase ELSE 0 END)-
	   SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END),2) AS growth_percent_2k19_2k20,

	   ROUND((SUM(total_revenue) FILTER(WHERE years = 2020)/SUM(total_purchase) FILTER(WHERE years = 2020))::NUMERIC,2) AS AOV_2020,
	   
	   ROUND(SUM(total_revenue) FILTER(WHERE years = 2020)::NUMERIC,2) AS total_revenue_2020,
	   
	   SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END) AS year_2019,
	   SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END) AS year_2018,
	   
       ROUND((SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END)-
	   SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END),2) AS growth_percent_2k18_2k19,

	   ROUND((SUM(total_revenue) FILTER(WHERE years = 2019)/SUM(total_purchase) FILTER(WHERE years = 2019)) ::NUMERIC,2) AS AOV_2019,

       ROUND(SUM(total_revenue) FILTER(WHERE years = 2019)::NUMERIC,2) AS total_revenue_2019,
	   
	   SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END) AS year_2018,
	   SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END) AS year_2017,
	   
	   ROUND((SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END)-
	   SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END),2) AS growth_percent_2k17_2k18,

	   ROUND((SUM(total_revenue) FILTER(WHERE years = 2018)/SUM(total_purchase) FILTER(WHERE years = 2018)) ::NUMERIC,2) AS AOV_2018,

       ROUND(SUM(total_revenue) FILTER(WHERE years = 2018)::NUMERIC,2) AS total_revenue_2018,

       SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END) AS year_2017,
	   SUM(CASE WHEN years = 2016 THEN total_purchase ELSE 0 END) AS year_2016,
	   
	   ROUND((SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END)-
	   SUM(CASE WHEN years = 2016 THEN total_purchase ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2016 THEN total_purchase ELSE 0 END),2) AS growth_percent_2k16_2k17,

	   ROUND((SUM(total_revenue) FILTER(WHERE years = 2017)/SUM(total_purchase) FILTER(WHERE years = 2017)) ::NUMERIC,2) AS AOV_2017,

       ROUND(SUM(total_revenue) FILTER(WHERE years = 2017)::NUMERIC,2) AS total_revenue_2017

	   FROM(
SELECT p.category,
       EXTRACT(YEAR FROM order_date) AS years, 
	   COUNT(DISTINCT order_number) AS total_purchase,
	   SUM(unit_price_usd*quantity) AS total_revenue
	   FROM sales s
       JOIN products p ON p.productkey = s.productkey
       GROUP BY p.category,
	            years 
       ORDER BY years,
	            p.category
)
GROUP BY category

-- Category & Subcategory Year-over-Year Performance Analysis

 	SELECT category, 
	       subcategory,
       SUM(CASE WHEN years = 2020 THEN total_purchase ELSE 0 END) AS year_2020,
	   SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END) AS year_2019,
	   
	   ROUND((SUM(CASE WHEN years = 2020 THEN total_purchase ELSE 0 END)-
	   SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END),2) AS growth_percent_2k19_2k20,

	   ROUND((SUM(total_revenue) FILTER(WHERE years = 2020)/SUM(total_purchase) FILTER(WHERE years = 2020))::NUMERIC,2) AS AOV_2020,
	   
	   ROUND(SUM(total_revenue) FILTER(WHERE years = 2020)::NUMERIC,2) AS total_revenue_2020,
	   
	   SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END) AS year_2019,
	   SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END) AS year_2018,
	   
       ROUND((SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END)-
	   SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END),2) AS growth_percent_2k18_2k19,

	   ROUND((SUM(total_revenue) FILTER(WHERE years = 2019)/SUM(total_purchase) FILTER(WHERE years = 2019)) ::NUMERIC,2) AS AOV_2019,

       ROUND(SUM(total_revenue) FILTER(WHERE years = 2019)::NUMERIC,2) AS total_revenue_2019,
	   
	   SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END) AS year_2018,
	   SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END) AS year_2017,
	   
	   ROUND((SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END)-
	   SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END),2) AS growth_percent_2k17_2k18,

	   ROUND((SUM(total_revenue) FILTER(WHERE years = 2018)/SUM(total_purchase) FILTER(WHERE years = 2018)) ::NUMERIC,2) AS AOV_2018,

       ROUND(SUM(total_revenue) FILTER(WHERE years = 2018)::NUMERIC,2) AS total_revenue_2018,

       SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END) AS year_2017,
	   SUM(CASE WHEN years = 2016 THEN total_purchase ELSE 0 END) AS year_2016,
	   
	   ROUND((SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END)-
	   SUM(CASE WHEN years = 2016 THEN total_purchase ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2016 THEN total_purchase ELSE 0 END),2) AS growth_percent_2k16_2k17,

	   ROUND((SUM(total_revenue) FILTER(WHERE years = 2017)/SUM(total_purchase) FILTER(WHERE years = 2017)) ::NUMERIC,2) AS AOV_2017,

       ROUND(SUM(total_revenue) FILTER(WHERE years = 2017)::NUMERIC,2) AS total_revenue_2017

	   FROM(
SELECT p.category,
       p.subcategory,
       EXTRACT(YEAR FROM order_date) AS years, 
	   COUNT(DISTINCT order_number) AS total_purchase,
	   SUM(unit_price_usd*quantity) AS total_revenue
	   FROM sales s
       JOIN products p ON p.productkey = s.productkey
       GROUP BY p.category,
	            p.subcategory,
	            years 
       ORDER BY years,
	            p.category,
				p.subcategory
)
GROUP BY category,
         subcategory
ORDER BY category,
         subcategory


-- Country-wise Category Performance Analysis

 	SELECT country,
	       category, 
       SUM(CASE WHEN years = 2020 THEN total_purchase ELSE 0 END) AS year_2020,
	   SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END) AS year_2019,
	   
	   ROUND((SUM(CASE WHEN years = 2020 THEN total_purchase ELSE 0 END)-
	   SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END),2) AS growth_percent_2k19_2k20,

	   ROUND(SUM(total_revenue) FILTER(WHERE years = 2020)::NUMERIC,2) AS total_revenue_2020,
	   ROUND(SUM(total_cost) FILTER(WHERE years = 2020)::NUMERIC,2) AS total_cost_2020,	   
	   
	   (ROUND(SUM(total_revenue) FILTER(WHERE years = 2020)::NUMERIC,2)-
	   ROUND(SUM(total_cost) FILTER(WHERE years = 2020)::NUMERIC,2)) AS total_profit_2020,

	   ROUND((SUM(total_revenue) FILTER(WHERE years = 2020)/SUM(total_purchase) FILTER(WHERE years = 2020))::NUMERIC,2) AS AOV_2020,
	   
	   SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END) AS year_2019,
	   SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END) AS year_2018,
	   
       ROUND((SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END)-
	   SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END),2) AS growth_percent_2k18_2k19,

       ROUND(SUM(total_revenue) FILTER(WHERE years = 2019)::NUMERIC,2) AS total_revenue_2019,
	   ROUND(SUM(total_cost) FILTER(WHERE years = 2019)::NUMERIC,2) AS total_cost_2019,

	   ROUND((SUM(total_revenue) FILTER(WHERE years = 2019)/SUM(total_purchase) FILTER(WHERE years = 2019))::NUMERIC,2) AS AOV_2019,

	   (ROUND(SUM(total_revenue) FILTER(WHERE years = 2019)::NUMERIC,2)-
	   ROUND(SUM(total_cost) FILTER(WHERE years = 2019)::NUMERIC,2)) AS total_profit_2019,
	   
	   SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END) AS year_2018,
	   SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END) AS year_2017,
	   
	   ROUND((SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END)-
	   SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END),2) AS growth_percent_2k17_2k18,

	   ROUND(SUM(total_revenue) FILTER(WHERE years = 2018)::NUMERIC,2) AS total_revenue_2018,
	   ROUND(SUM(total_cost) FILTER(WHERE years = 2018)::NUMERIC,2) AS total_cost_2018,

	   (ROUND(SUM(total_revenue) FILTER(WHERE years = 2018)::NUMERIC,2)-
	   ROUND(SUM(total_cost) FILTER(WHERE years = 2018)::NUMERIC,2)) AS total_profit_2018,

	   ROUND((SUM(total_revenue) FILTER(WHERE years = 2018)/SUM(total_purchase) FILTER(WHERE years = 2018))::NUMERIC,2) AS AOV_2018,

       SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END) AS year_2017,
	   SUM(CASE WHEN years = 2016 THEN total_purchase ELSE 0 END) AS year_2016,
	   
	   ROUND((SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END)-
	   SUM(CASE WHEN years = 2016 THEN total_purchase ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2016 THEN total_purchase ELSE 0 END),2) AS growth_percent_2k16_2k17,

	   ROUND(SUM(total_revenue) FILTER(WHERE years = 2017)::NUMERIC,2) AS total_revenue_2017,
	   ROUND(SUM(total_cost) FILTER(WHERE years = 2017)::NUMERIC,2) AS total_cost_2017,

	   ROUND(SUM(total_revenue) FILTER(WHERE years = 2017)::NUMERIC,2)-
	   ROUND(SUM(total_cost) FILTER(WHERE years = 2017)::NUMERIC,2) AS total_profit_2017,

	   ROUND((SUM(total_revenue) FILTER(WHERE years = 2017)/SUM(total_purchase) FILTER(WHERE years = 2017))::NUMERIC,2) AS AOV_2017
	   
	   FROM(
SELECT st.country,
       p.category,
       EXTRACT(YEAR FROM order_date) AS years, 
	   COUNT(DISTINCT order_number) AS total_purchase,
	   SUM(unit_price_usd*quantity) AS total_revenue,
	   SUM(unit_cost_usd*quantity) AS total_cost
	   FROM sales s
       JOIN products p ON p.productkey = s.productkey
	   JOIN stores st ON st.storekey = s.storekey
       GROUP BY p.category,
	            st.country,
	            years 
       ORDER BY years,
	            st.country,
	            p.category
)
GROUP BY  country,
          category
ORDER BY  country,
          category	


-- Subcategory Revenue Contribution

WITH cte AS (
SELECT subcategory,
       ROUND(SUM(unit_price_usd * quantity)::NUMERIC,2) AS revenue
FROM sales s
JOIN products p
ON p.productkey = s.productkey
GROUP BY subcategory
),

cte2 AS (
SELECT *,
       ROUND(
       revenue * 100.0 /
       SUM(revenue) OVER()::NUMERIC,
       2
       ) AS revenue_percent
FROM cte
)
SELECT *,
       ROUND(
       SUM(revenue_percent)
       OVER(
       ORDER BY revenue DESC
       ),
       2
       ) AS cumulative_percent
FROM cte2
ORDER BY revenue DESC

/*==============================================================

Section 7
Exploratory dimension 

==============================================================*/

WITH first_order AS(
SELECT customerkey, 
       MIN(EXTRACT(YEAR FROM order_date)) AS first_order_year 
	   FROM sales
	   GROUP BY customerkey
),
customer_orders AS(
SELECT c.customerkey, 
       CASE
         WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) < 18 THEN 'Under 18'
         WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 18 AND 30 THEN '18-30'
         WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 31 AND 45 THEN '31-45'
         WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 46 AND 60 THEN '46-60'
         ELSE '60+'
       END AS age_group,
	     EXTRACT(YEAR FROM order_date) AS order_year,
	     COUNT(DISTINCT order_number) AS total_orders,
		 SUM(unit_price_usd*quantity) AS total_revenue
		 FROM sales s
		 JOIN customers c ON c.customerkey = s.customerkey
		 JOIN products p ON p.productkey = s.productkey
		 GROUP BY c.customerkey,
		          age_group,
				  order_year
),
final_query AS(
SELECT fo.customerkey, 
       co.customerkey, 
	   co.age_group,
	   co.order_year, 
	   fo.first_order_year, 
	   total_orders,
	   total_revenue,
	   CASE WHEN fo.first_order_year = co.order_year THEN 'New customer'
	   ELSE 'Existing customer' END AS customer_groups
	   FROM first_order fo JOIN customer_orders co ON fo.customerkey = co.customerkey
)
SELECT age_group, 
       order_year, 
	   customer_groups,
	   COUNT(*) AS total_customers, 
	   SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
	   ROUND(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)*100.0/COUNT(*),2) repeat_customers_percent,
	   ROUND(SUM(total_revenue) FILTER(WHERE total_orders > 1)::NUMERIC,2) AS revenue_contribution,
	   ROUND(SUM(total_revenue) FILTER(WHERE total_orders > 1)::NUMERIC*100.0/SUM(total_revenue)::NUMERIC,2) AS revenue_contribution_percent
FROM final_query
GROUP BY age_group, 
         order_year,
		 customer_groups
ORDER BY order_year,
         age_group

-- exploratory folder

WITH base_table AS(
SELECT CASE
         WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) < 18 THEN 'Under 18'
         WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 18 AND 30 THEN '18-30'
         WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 31 AND 45 THEN '31-45'
         WHEN EXTRACT(YEAR FROM AGE(order_date,birthday)) BETWEEN 46 AND 60 THEN '46-60'
         ELSE '60+'
       END AS age_group,
       c.customerkey, 
	   EXTRACT(YEAR FROM order_date) AS years, 
	   COUNT(DISTINCT order_number) AS total_orders,
	   SUM(unit_price_usd*quantity) AS total_revenue 
	   FROM sales s
JOIN customers c ON c.customerkey = s.customerkey
JOIN products p ON p.productkey = s.productkey
GROUP BY years,
		 c.customerkey,
		 age_group
)
SELECT years,
       age_group,
       COUNT(*) AS total_customers,
	   SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
	   ROUND(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS repeat_customers_percent,
	   ROUND(SUM(CASE WHEN total_orders > 1 THEN total_revenue ELSE 0 END)::NUMERIC,2) AS repeat_customers_revenue
	   FROM base_table
       GROUP BY years,age_group
	   ORDER BY years,age_group

-- checking if their any boom in specific category in 2k19 so the purchase is increasing

SELECT category, 
       years,
	   total_purchase,
	   ROUND(total_purchase*100.0/SUM(total_purchase) OVER(PARTITION BY years),2) AS total_purchase_percent
	   FROM(
SELECT p.category,
       EXTRACT(YEAR FROM order_date) AS years,
	   COUNT(*) AS total_purchase
       FROM sales s
       JOIN products p ON p.productkey = s.productkey
GROUP BY p.category,
         years
ORDER BY years,
         p.category
)


-- exploratory folder

SELECT DATE_TRUNC('month',order_date) AS monthly_purchase, 
       COUNT(*) AS total_purchase,
       SUM(unit_price_usd*quantity) AS total_revenue FROM sales s
       JOIN products p ON p.productkey = s.productkey
       GROUP BY monthly_purchase 
       ORDER BY monthly_purchase

-- exploratory folder

SELECT country, 
       category, 
	   subcategory, 
	   COUNT(DISTINCT order_number) FILTER(WHERE EXTRACT(YEAR FROM order_date) = 2019) AS total_purchase,
COUNT(*) FILTER(WHERE EXTRACT(YEAR FROM order_date) = 2018) total_purchase_2018, SUM(unit_price_usd*quantity) AS total_revenue FROM sales s
JOIN products p ON s.productkey = p.productkey
JOIN customers c ON c.customerkey = s.customerkey
WHERE category = 'Home Appliances'
GROUP BY country, category, subcategory
ORDER BY subcategory,category,country

-- exploratory folder

SELECT s1.country, 
       c.country, 
	   p.category, 
	   SUM(CASE WHEN EXTRACT(year FROM order_date) = 2019 THEN 1 ELSE 0 END) total_purchase_2019,
       ROUND(SUM(unit_price_usd*quantity) FILTER(WHERE EXTRACT(year FROM order_date) = 2019)::NUMERIC,2) AS total_sales,
       SUM(CASE WHEN EXTRACT(year FROM order_date) = 2018 THEN 1 ELSE 0 END) total_purchase_2020,
       ROUND(SUM(unit_price_usd*quantity) FILTER(WHERE EXTRACT(year FROM order_date) = 2018)::NUMERIC,2) total_sales,
       SUM(CASE WHEN EXTRACT(year FROM order_date) = 2017 THEN 1 ELSE 0 END) total_purchase_2017,
       ROUND(SUM(unit_price_usd*quantity) FILTER(WHERE EXTRACT(year FROM order_date) = 2017)::NUMERIC,2) total_sales FROM sales s
       JOIN stores s1 ON s1.storekey = s.storekey
       JOIN products p ON p.productkey = s.productkey
       JOIN customers c ON c.customerkey = s.customerkey
       WHERE s1.country = 'Online' AND category = 'TV and Video'
       GROUP BY s1.country, 
	            c.country, 
				p.category
       ORDER BY c.country, 
	            p.category

-- exploratory folder

(SELECT CASE WHEN s1.country = 'Online' THEN 'USA Online' 
            ELSE 'USA Offline' END AS purchase_mode,
		COUNT(*) AS total_purchase,
		ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS total_revenue
			FROM sales s
			JOIN products p ON p.productkey = s.productkey
			JOIN stores s1 ON s1.storekey = s.storekey
			JOIN customers c ON c.customerkey = s.customerkey
			WHERE c.country = 'United States'
			GROUP BY purchase_mode
UNION ALL
SELECT CASE WHEN s1.country = 'Online' THEN 'other countries Online' ELSE 'other countries Offline' 
            END AS purchase_mode,
		COUNT(*) AS total_purchase,
		ROUND(SUM(unit_price_usd*quantity)::NUMERIC,2) AS total_revenue
			FROM sales s
			JOIN products p ON p.productkey = s.productkey
			JOIN stores s1 ON s.storekey = s1.storekey
			JOIN customers c ON c.customerkey = s.customerkey
			WHERE c.country <> 'United States'
			GROUP BY purchase_mode)

-- exploratory folder

 	SELECT country,
	       category, 
       SUM(CASE WHEN years = 2020 THEN total_purchase ELSE 0 END) AS year_2020,
	   SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END) AS year_2019,
	   
	   ROUND((SUM(CASE WHEN years = 2020 THEN total_purchase ELSE 0 END)-
	   SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END),2) AS growth_percent_2k19_2k20,

	   ROUND(SUM(total_revenue) FILTER(WHERE years = 2020)::NUMERIC,2) AS total_revenue_2020,
	   ROUND(SUM(total_cost) FILTER(WHERE years = 2020)::NUMERIC,2) AS total_cost_2020,	   
	   
	   (ROUND(SUM(total_revenue) FILTER(WHERE years = 2020)::NUMERIC,2)-
	   ROUND(SUM(total_cost) FILTER(WHERE years = 2020)::NUMERIC,2)) AS total_profit,

	   ROUND((SUM(total_revenue) FILTER(WHERE years = 2020)/SUM(total_purchase) FILTER(WHERE years = 2020))::NUMERIC,2) AS AOV_2020,
	   
	   SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END) AS year_2019,
	   SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END) AS year_2018,
	   
       ROUND((SUM(CASE WHEN years = 2019 THEN total_purchase ELSE 0 END)-
	   SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END),2) AS growth_percent_2k18_2k19,

       ROUND(SUM(total_revenue) FILTER(WHERE years = 2019)::NUMERIC,2) AS total_revenue_2019,
	   ROUND(SUM(total_cost) FILTER(WHERE years = 2019)::NUMERIC,2) AS total_cost_2019,

	   ROUND((SUM(total_revenue) FILTER(WHERE years = 2019)/SUM(total_purchase) FILTER(WHERE years = 2019))::NUMERIC,2) AS AOV_2019,

	   (ROUND(SUM(total_revenue) FILTER(WHERE years = 2019)::NUMERIC,2)-
	   ROUND(SUM(total_cost) FILTER(WHERE years = 2019)::NUMERIC,2)) AS total_profit,
	   
	   SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END) AS year_2018,
	   SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END) AS year_2017,
	   
	   ROUND((SUM(CASE WHEN years = 2018 THEN total_purchase ELSE 0 END)-
	   SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END),2) AS growth_percent_2k17_2k18,

	   ROUND(SUM(total_revenue) FILTER(WHERE years = 2018)::NUMERIC,2) AS total_revenue_2018,
	   ROUND(SUM(total_cost) FILTER(WHERE years = 2018)::NUMERIC,2) AS total_cost_2018,

	   (ROUND(SUM(total_revenue) FILTER(WHERE years = 2018)::NUMERIC,2)-
	   ROUND(SUM(total_cost) FILTER(WHERE years = 2018)::NUMERIC,2)) AS total_profit,

	   ROUND((SUM(total_revenue) FILTER(WHERE years = 2018)/SUM(total_purchase) FILTER(WHERE years = 2018))::NUMERIC,2) AS AOV_2018,

       SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END) AS year_2017,
	   SUM(CASE WHEN years = 2016 THEN total_purchase ELSE 0 END) AS year_2016,
	   
	   ROUND((SUM(CASE WHEN years = 2017 THEN total_purchase ELSE 0 END)-
	   SUM(CASE WHEN years = 2016 THEN total_purchase ELSE 0 END))*100.0/
	   SUM(CASE WHEN years = 2016 THEN total_purchase ELSE 0 END),2) AS growth_percent_2k16_2k17,

	   ROUND(SUM(total_revenue) FILTER(WHERE years = 2017)::NUMERIC,2) AS total_revenue_2017,
	   ROUND(SUM(total_cost) FILTER(WHERE years = 2017)::NUMERIC,2) AS total_cost_2017,

	   ROUND(SUM(total_revenue) FILTER(WHERE years = 2017)::NUMERIC,2)-
	   ROUND(SUM(total_cost) FILTER(WHERE years = 2017)::NUMERIC,2) AS total_profit,

	   ROUND((SUM(total_revenue) FILTER(WHERE years = 2017)/SUM(total_purchase) FILTER(WHERE years = 2017))::NUMERIC,2) AS AOV_2017
	   
	   FROM(
SELECT st.country,
       p.category,
       EXTRACT(YEAR FROM order_date) AS years, 
	   COUNT(*) AS total_purchase,
	   SUM(unit_price_usd*quantity) AS total_revenue,
	   SUM(unit_cost_usd*quantity) AS total_cost
	   FROM sales s
       JOIN products p ON p.productkey = s.productkey
	   JOIN stores st ON st.storekey = s.storekey
	   WHERE st.country = 'Italy'
       GROUP BY p.category,
	            st.country,
	            years 
       ORDER BY years,
	            st.country,
	            p.category
)
GROUP BY  country,
          category
ORDER BY  country,
          category	

-- exploratory folder

SELECT p.category, 
       COUNT(DISTINCT order_number) AS total_sold 
	   FROM products p
JOIN sales s ON p.productkey = s.productkey
GROUP BY p.category
ORDER BY total_sold DESC

-- exploratory folder

SELECT COUNT(DISTINCT customerkey) purchase_of_customers FROM(
SELECT c.customerkey,
       birthday,
       order_date,
       EXTRACT(YEAR FROM AGE(order_date, birthday)) AS age
FROM sales s
JOIN customers c
ON s.customerkey = c.customerkey
JOIN products p 
ON p.productkey = s.productkey
WHERE EXTRACT(YEAR FROM AGE(order_date, birthday)) < 18
AND p.category = 'Home Appliances'
)


/*==============================================================

Section 6
Opportunity Analysis

==============================================================*/

-- Customer Retention Opportunities

WITH cte AS(
SELECT customerkey, 
       MAX(order_date) customer_last_order_date,
	   SUM(unit_price_usd*quantity)::numeric AS total_revenue FROM sales s
JOIN products p ON p.productkey = s.productkey
GROUP BY customerkey
),
cte2 AS(
SELECT  MAX(order_date) last_order_in_dataset FROM sales
)
SELECT last_order_in_dataset, 
       COUNT(*) AS total_customers, 
	   ROUND(SUM(total_revenue),2) AS total_revenue,
	   ROUND(SUM(total_revenue) FILTER(WHERE customer_last_order_date <= last_order_in_dataset - INTERVAL '1 YEAR')*100.0/SUM(total_revenue),2) AS inactive_1_year_revenue,
	   ROUND(SUM(total_revenue) FILTER(WHERE customer_last_order_date <= last_order_in_dataset - INTERVAL '2 YEAR')*100.0/SUM(total_revenue),2) AS inactive_2_year_revenue,
	   COUNT(*) FILTER(WHERE EXTRACT(YEAR FROM customer_last_order_date) = 2019) AS inactive_from_2019,
	   ROUND(COUNT(*) FILTER(WHERE EXTRACT(YEAR FROM customer_last_order_date) = 2019)*100.0/COUNT(*),2) AS inactive_from_2019_percent,
	   COUNT(*) FILTER(WHERE customer_last_order_date <= last_order_in_dataset - INTERVAL '1 year') AS inactive_1_year,
	   COUNT(*) FILTER(WHERE customer_last_order_date <= last_order_in_dataset - INTERVAL '2 year') AS incative_2_year,
	   ROUND(COUNT(*) FILTER(WHERE customer_last_order_date <= last_order_in_dataset - INTERVAL '1 year')*100.0/COUNT(*),2) AS inactive_1_year_percent,
	   ROUND(COUNT(*) FILTER(WHERE customer_last_order_date <= last_order_in_dataset - INTERVAL '2 year')*100.0/COUNT(*),2) AS incative_2_year_percent
FROM cte ct
CROSS JOIN cte2 ct1
GROUP BY last_order_in_dataset

-- Customer Retention & Inactivity Analysis

WITH cte AS (
SELECT
    customerkey,
    MAX(order_date) AS customer_last_order_date,
    SUM(unit_price_usd * quantity)::numeric AS total_revenue,
    COUNT(DISTINCT order_number) AS total_orders
FROM sales s
JOIN products p
ON p.productkey = s.productkey
GROUP BY customerkey
)
SELECT CASE WHEN EXTRACT(YEAR FROM customer_last_order_date) = 2016 THEN 'last_order_2016' 
            WHEN EXTRACT(YEAR FROM customer_last_order_date) = 2017 THEN 'last_order_2017'
			WHEN EXTRACT(YEAR FROM customer_last_order_date) = 2018 THEN 'last_order_2018'
			WHEN EXTRACT(YEAR FROM customer_last_order_date) = 2019 THEN 'last_order_2019'
			WHEN EXTRACT(YEAR FROM customer_last_order_date) = 2020 THEN 'last_order_2020'
			ELSE 'last_order_2021' END AS customer_status,
			COUNT(*) AS total_customers,
			ROUND(SUM(total_orders)/COUNT(DISTINCT customerkey),2) Average_order_per_customer,
			SUM(total_revenue) AS revenue_contribution,
			ROUND(SUM(total_revenue)/SUM(total_orders),2) AS AOV,
			ROUND(SUM(total_revenue)/COUNT(*),2) AS average_revenue_per_customer
			FROM cte
			GROUP BY customer_status
			ORDER BY customer_status

-- Customer Re-engagement Opportunities

WITH cte AS (
SELECT
    c.customerkey,
	birthday,
    MAX(order_date) AS customer_last_order_date,
    SUM(unit_price_usd * quantity)::numeric AS total_revenue,
    COUNT(DISTINCT order_number) AS total_orders
FROM sales s
JOIN products p
ON p.productkey = s.productkey
JOIN customers c ON c.customerkey = s.customerkey
GROUP BY c.customerkey,birthday
),
cte2 AS(
SELECT customerkey,
       	CASE
         WHEN EXTRACT(YEAR FROM AGE(customer_last_order_date,birthday)) < 18 THEN 'Under 18'
         WHEN EXTRACT(YEAR FROM AGE(customer_last_order_date,birthday)) BETWEEN 18 AND 30 THEN '18-30'
         WHEN EXTRACT(YEAR FROM AGE(customer_last_order_date,birthday)) BETWEEN 31 AND 45 THEN '31-45'
         WHEN EXTRACT(YEAR FROM AGE(customer_last_order_date,birthday)) BETWEEN 46 AND 60 THEN '46-60'
         ELSE '60+'
       END AS age_group,
	   customer_last_order_date,
	   total_revenue,
	   total_orders
	   FROM cte
),
cte3 AS(
SELECT age_group,
           CASE WHEN EXTRACT(YEAR FROM customer_last_order_date) = 2016 THEN 'last_order_2016' 
            WHEN EXTRACT(YEAR FROM customer_last_order_date) = 2017 THEN 'last_order_2017'
			WHEN EXTRACT(YEAR FROM customer_last_order_date) = 2018 THEN 'last_order_2018'
			WHEN EXTRACT(YEAR FROM customer_last_order_date) = 2019 THEN 'last_order_2019'
			WHEN EXTRACT(YEAR FROM customer_last_order_date) = 2020 THEN 'last_order_2020'
			ELSE 'last_order_2021' END AS customer_status,
			COUNT(*) AS inactive_customers_2019,
			ROUND(SUM(total_orders)/COUNT(*),2) Average_order_per_customer,
			ROUND(SUM(total_revenue),2) AS revenue_contribution,
			ROUND(SUM(total_revenue)/SUM(total_orders),2) AS AOV,
			ROUND(SUM(total_revenue)/COUNT(*),2) AS average_revenue_per_customer
			FROM cte2
			GROUP BY age_group,customer_status
			ORDER BY customer_status,age_group
)
SELECT age_group, 
       customer_status,
	   inactive_customers_2019,
	   Average_order_per_customer,
	   revenue_contribution,
	   AOV,
	   average_revenue_per_customer
	   FROM cte3
	   WHERE customer_status = 'last_order_2019'








