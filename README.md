# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: SQL Retail Sales P1
**Database**: `project_1`


This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. 

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `prject_1`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE project_1;

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
```

### 2. Data Cleaning
- **NULL Value Check:** Check if there are any NULL values in the dataset and delete records which have missing data. 
```sql
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
 ```
### 3. Exploratory Data Analysis (EDA)
- **Record Count:** Find out how many transactions were made/total number of records in the dataset. 
- **Customer Count:** Determine how many unique customers are in the dataset. 
- **Category count:** Understand all categories of product we have their quantity sold in the dataset. 

```sql 
-- 1. How many tracsaction 
SELECT COUNT(*) AS NumberOfTransaction FROM retail_sales; 

-- 2. How many (distinct) customer 
SELECT COUNT(DISTINCT customer_id) AS NumberOfCusotmer FROM retail_sales; 

-- 3. What are the categories we have
SELECT category, SUM(quantity) AS QuantitySold FROM retail_sales GROUP BY category; 
```
 
### 4. Data Analysis 

The following SQL queries were developed to answer specific business questions:
1. **Write a SQL query to retrieve all columns for sales made on '2022-11-05:**
```sql
SELECT * FROM retail_sales 
WHERE sale_date = '2022-11-05';
```

2. ***Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is equal or greater than 4 in the month of Nov-2022**
```sql
SELECT * FROM retail_sales -- Approach1: using date manipulation function
WHERE category = 'Clothing' 
AND quantity >=4 
AND MONTH(sale_date) = 11
AND YEAR(sale_date) = 2022; 

SELECT * FROM retail_sales -- Approach2: using date formatting function 
WHERE category = 'Clothing' 
AND quantity >=4 
AND DATE_FORMAT(sale_date, '%m-%Y') = '11-2022'; 
```
 
3. **Write a SQL query to calculate the total sales (total_sale) and number of transactions for each category**
``` sql
SELECT category, SUM(total_sale) as NetSales, COUNT(*) as NumberOfTransactions
FROM retail_sales 
GROUP BY category; 
```

4. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.**:
```sql
SELECT category, AVG(age) AS AvgAge 
FROM retail_sales 
WHERE category = 'Beauty';
```

5. **Write a SQL query to find all transactions where the total_sale is greater than 1000.**:
```sql
SELECT * FROM retail_sales
WHERE total_sale > 1000
```

6. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql
SELECT gender, category, count(customer_id) as NumberofTrans
FROM retail_sales
GROUP BY gender, category; 
```

7. **Write a SQL query to calculate the average sale for each month. Find out best selling time/best selling month in each year**:
```sql
SELECT   -- Approach1: Without CTE query 
 MONTH(sale_date) as month, 
 YEAR(sale_date) as year,
 AVG(total_sale) as avgSale 
FROM retail_sales 
GROUP BY month, year; 

WITH monthlySales AS  -- Approach2: With CTE query 
(SELECT
  MONTH(sale_date) as month,
  YEAR(sale_date) as year,
  avg(total_sale) as avg_sale,
  rank() over (partition BY YEAR(sale_date) ORDER BY avg(total_sale) DESC) as ranking
 FROM retail_sales 
 GROUP BY month, year)
 SELECT month, year, avg_sale, ranking 
 FROM monthlySales; 
 
 WITH monthlySales AS -- Find out best selling time regardless of which year it is 
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
  
  -- Find out the best selling month in each year 
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
```

8. **Write a SQL query to find the top 5 customers based on the highest total sales**:
```sql
SELECT Distinct customer_id, SUM(total_sale) as totalSales
FROM retail_sales 
GROUP BY customer_id
ORDER BY SUM(total_sale) DESC 
LIMIT 5; 
```

9. **Write a SQL query to find the number of unique customers who purchased items from each category.**:
```sql
SELECT COUNT(DISTINCT customer_id) as NumUniqueCustomer, Category 
FROM retail_sales 
GROUP BY category; 
```

10. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
SELECT COUNT(transactions_id),   -- Using subquery 
  CASE 
    WHEN HOUR(sale_time) < 12 THEN 'MORNING' 
    WHEN HOUR(sale_time) BETWEEN 12 and 17 THEN 'AFTERNOON' 
    ELSE 'EVENING' 
   END AS shift 
FROM retail_sales 
GROUP BY shift; 

WITH shiftInfo AS -- Using CTE
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
 FROM shiftInfo 
 GROUP BY shift; 
```

## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories Clothing, Electronics and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.


## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.

## How to Use

1. **Clone the Repository**: Clone this project repository from GitHub.
2. **Set Up the Database**:  Run the SQL scripts provided in the `SQL_RetailSalesProject.sql` file to create, import the data from ``` SQL-RetailSalesAnalysis_utf.csv ``` file provided into **MySQL Workbench** to populate the database.
3. **Run the Queries**: Use the SQL queries provided in the `SQL_RetailSalesProject.sql` file to perform your analysis.
4. **Explore and Modify**: Feel free to modify the queries to explore different aspects of the dataset or answer additional business questions.

## Author - Khanh Linh 

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

### Stay Updated

For more content on SQL, data analysis, and other data-related topics, stay connected me on social media: 

- **LinkedIn**: https://www.linkedin.com/in/khanh-linhh-5ba214233/ 

Thank you for your support, and I look forward to connecting with you!
