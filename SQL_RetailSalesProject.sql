-- Setup database and insert data 
CREATE DATABASE project_1; 
USE project_1; 
CREATE TABLE IF NOT EXISTS retail_sales 
(
 transactions_id    INT, 
 sale_date          DATE,
 sale_time          TIME,
 customer_id        INT,
 gender             VARCHAR(20),
 age                INT,
 category           VARCHAR(50),
 quantity           INT, 
 price_per_unit     FLOAT,
 cogs               FLOAT,
 total_sale         FLOAT
 ); 

-- Data cleaning: identify and remove any records having NULL values
SELECT * FROM retail_sales WHERE  
 transactions_id IS NULL OR  
 sale_date       IS NULL OR
 sale_time       IS NULL OR
 customer_id     IS NULL OR
 gender          IS NULL OR
 age             IS NULL OR
 category        IS NULL OR
 quantity        IS NULL OR
 price_per_unit  IS NULL OR
 cogs            IS NULL OR
 total_sale      IS NULL; 
 
DELETE FROM retail_sales WHERE 
  transactions_id IS NULL OR  
 sale_date       IS NULL OR
 sale_time       IS NULL OR
 customer_id     IS NULL OR
 gender          IS NULL OR
 age             IS NULL OR
 category        IS NULL OR
 quantity        IS NULL OR
 price_per_unit  IS NULL OR
 cogs            IS NULL OR
 total_sale      IS NULL; 

-- EDA: Exploratory Data Analysis 
-- 1. How many tracsaction 
SELECT COUNT(*) AS NumberOfTransaction FROM retail_sales; 

-- 2. How many (distinct) customer 
SELECT COUNT(DISTINCT customer_id) AS NumberOfCusotmer FROM retail_sales; 

-- 3. What are the categories we have
SELECT category, SUM(quantity) AS QuantitySold FROM retail_sales GROUP BY category; 

-- Data Analysis & Business Key Problems & Answers
SELECT * FROM retail_sales; 

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
SELECT * FROM retail_sales 
WHERE sale_date = '2022-11-05';

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is equal or greater than 4 in the month of Nov-2022
SELECT * FROM retail_sales 
WHERE category = 'Clothing' 
AND quantity >=4 
AND MONTH(sale_date) = 11
AND YEAR(sale_date) = 2022; 

SELECT * FROM retail_sales 
WHERE category = 'Clothing' 
AND quantity >=4 
AND DATE_FORMAT(sale_date, '%m-%Y') = '11-2022'; 

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
SELECT category, SUM(total_sale) 
FROM retail_sales 
GROUP BY category; 

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT category, AVG(age) AS AvgAge 
FROM retail_sales 
WHERE category = 'Beauty' 
GROUP BY category; 

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT * FROM retail_sales 
WHERE total_sale > 1000; 

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
SELECT gender, category, count(distinct customer_id) 
FROM retail_sales
GROUP BY gender, category; 

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
SELECT 
 MONTH(sale_date) as month, 
 YEAR(sale_date) as year,
 AVG(total_sale) as avgSale 
FROM retail_sales 
GROUP BY month, year; 

WITH monthlySales AS
(SELECT
 MONTH(sale_date) as month,
 YEAR(sale_date) as year,
 avg(total_sale) as avg_sale,
 rank() over (partition BY YEAR(sale_date) ORDER BY avg(total_sale) DESC) as ranking
 FROM retail_sales 
 GROUP BY month, year)
 SELECT month, year, avg_sale, ranking 
 FROM monthlySales; 
 
 WITH monthlySales AS -- Find out best selling time regardless of which year 
 ( 
  SELECT MONTH(sale_date) AS month,
  YEAR(sale_date) AS year,
  AVG(total_sale) as avgSale,
  RANK() OVER (ORDER BY AVG(total_sale) DESC) as ranking 
  FROM retail_sales
  GROUP BY month, year
  )
  SELECT month, year, avgSale, ranking
  FROM monthlySales;
  
  -- Find out the best month in each year 
  WITH monthlysales AS 
  (
    SELECT 
    MONTH(sale_date) AS month,
    YEAR(sale_date) AS year, 
    AVG(total_sale) AS avgsale,
    RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY  AVG(total_sale) DESC) AS ranking
    FROM retail_sales
    GROUP BY month, year
    )
    SELECT month, year, avgsale, ranking
    FROM monthlysales 
    WHERE ranking = 1; 
    
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
SELECT Distinct customer_id, SUM(total_sale)
FROM retail_sales 
GROUP BY customer_id
ORDER BY SUM(total_sale) DESC 
LIMIT 5; 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT COUNT(DISTInCT customer_id), category 
FROM retail_sales 
GROUP BY category; 

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
SELECT COUNT(transactions_id), 
  CASE 
    WHEN HOUR(sale_time) <= 12 THEN 'Morning' 
    WHEN HOUR(sale_time) BETWEEN 12 and 17 THEN 'AFTERNOON' 
    ELSE 'EVENING' 
   END AS shift 
FROM retail_sales 
GROUP BY shift; 

WITH shiftInfo AS
(
 SELECT *,
  CASE
   WHEN HOUR(sale_time) < 12 THEN 'Morning' 
   WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon' 
   WHEN HOUR(sale_time)  > 17 THEN 'Evening' 
   END AS shift 
   FROM retail_sales
   )
   SELECT shift, COUNT(transactions_id) AS NUmberOfOrder 
   from shiftInfo 
   GROUP BY shift; 