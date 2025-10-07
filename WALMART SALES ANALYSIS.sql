CREATE DATABASE WALMART_SALES_DATA;

CREATE TABLE SALES(
INVOICE_ID VARCHAR(30) NOT NULL PRIMARY KEY,
BRANCH VARCHAR(5) NOT NULL,
CITY VARCHAR(30) NOT NULL,
CUSTOMER_TYPE VARCHAR(30) NOT NULL,
GENDER VARCHAR(10) NOT NULL,
PRODUCT_LINE VARCHAR(100) NOT NULL,
UNIT_PRICE DECIMAL(10,2) NOT NULL,
QUANTITY INT NOT NULL,
VAT FLOAT(6,4) NOT NULL,
TOTAL DECIMAL(12,4) NOT NULL,
DATE DATETIME NOT NULL,
TIME TIME NOT NULL,
PAYMENT_METHOD VARCHAR(15) NOT NULL,
COGS DECIMAL(10,2) NOT NULL,
GROSS_MARGIN_PCT FLOAT(11,9),
GROSS_INCOME DECIMAL (12,4) NOT NULL ,
RATING FLOAT(2,1)
);

SELECT*FROM SALES;
-- ==========================================================================================================================================================================================================
-- ------------------------------------------------------------------------------ Generic Question-----------------------------------------------------------------------------------------------------------
-- Q1 How many unique cities does the data have?
select distinct city from sales;

-- Q2 In which city is each branch?
select DISTINCT CITY, BRANCH FROM SALES;
SELECT * FROM SALES; 

-- ===========================================================================================================================================================================================================
-- -----------------------------------------------------------------------------------PRODUCT----------------------------------------------------------------------------------------------------------------
-- Q1 How many unique product lines does the data have?
 SELECT DISTINCT PRODUCT_LINE FROM SALES ; 

-- Q2 What is the most common payment method?
SELECT PAYMENT_METHOD, COUNT(PAYMENT_METHOD) FROM SALES GROUP BY PAYMENT_METHOD ORDER BY COUNT(PAYMENT_METHOD) DESC LIMIT  1 ;

-- Q3 What is the most selling product line?
SELECT PRODUCT_LINE,COUNT(PRODUCT_LINE) FROM SALES GROUP BY PRODUCT_LINE ORDER BY COUNT(PRODUCT_LINE) DESC  LIMIT 1 ;

-- Q4 What is the total revenue by month?
SELECT  MONTH_NAME AS MONTH , SUM(TOTAL) AS TOTAL_REVENUE FROM SALES GROUP BY MONTH ORDER BY TOTAL_REVENUE;

-- Q5 What month had the largest COGS?
SELECT MONTH_NAME AS MONTH , SUM(COGS) FROM SALES GROUP BY MONTH ORDER BY SUM(COGS) DESC ;

-- Q6 What product line had the largest revenue?
SELECT PRODUCT_LINE , SUM(TOTAL) FROM SALES GROUP BY PRODUCT_LINE ORDER BY SUM(TOTAL) DESC ;

-- Q7 What is the city with the largest revenue?
SELECT CITY , SUM(TOTAL) FROM SALES GROUP BY CITY ORDER BY SUM(TOTAL) DESC ; 

-- Q8 What product line had the largest VAT?
SELECT PRODUCT_LINE ,SUM(VAT) FROM SALES GROUP BY PRODUCT_LINE ORDER BY SUM(VAT) DESC LIMIT 3 ;

-- Q9 Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT PRODUCT_LINE,AVG(TOTAL) AS AVG_SALE ,
CASE  
	WHEN AVG(TOTAL) > (SELECT AVG(TOTAL) FROM  SALES ) THEN "GOOD"
	ELSE "BAD" END  AS PERFORMANCE
FROM SALES GROUP BY PRODUCT_LINE;

ALTER TABLE SALES ADD COLUMN PERFORMANCE VARCHAR(10);

UPDATE SALES 
JOIN(
SELECT PRODUCT_LINE,
CASE WHEN AVG(TOTAL) > (SELECT AVG(TOTAL) FROM SALES ) THEN "GOOD"
ELSE "BAD" END AS PERFORMANCE 
FROM SALES 
GROUP BY PRODUCT_LINE) AS AVG_TABLE
ON SALES.PRODUCT_LINE = AVG_TABLE.PRODUCT_LINE 
SET SALES.PERFORMANCE= AVG_TABLE.PERFORMANCE ;
SELECT* FROM SALES ;

ALTER TABLE SALES DROP COLUMN PERFORMANCE;

SELECT*FROM SALES ;

-- Q10 Which branch sold more products than average product sold?
SELECT * FROM SALES ;
SELECT BRANCH , SUM(QUANTITY)AS TOTAL_QUANTITY
FROM SALES 
GROUP BY BRANCH HAVING TOTAL_QUANTITY > 
(SELECT AVG(TOTAL_QUANTITY) FROM 
 (SELECT SUM(QUANTITY)AS TOTAL_QUANTITY FROM SALES GROUP BY BRANCH) AS A );

-- Q11 What is the most common product line by gender?
SELECT * FROM SALES ; 
SELECT GENDER ,PRODUCT_LINE,COUNT(GENDER)
FROM SALES GROUP BY GENDER, PRODUCT_LINE
ORDER BY COUNT(GENDER) DESC;

-- Q12 What is the average rating of each product line?
SELECT ROUND(AVG(RATING),2) AS AVG_RATING , PRODUCT_LINE FROM SALES GROUP  BY PRODUCT_LINE ORDER BY AVG_RATING DESC ;

-- ==========================================================================================================================================================================================================
-- -----------------------------------------------------------------------------------------------SALES -----------------------------------------------------------------------------------------------------

-- Q1 Number of sales made in each time of the day per weekday
select* from sales ;
SELECT TIME ,
(CASE
	WHEN TIME between "00:00:00" AND "12:00:00" THEN "MORNING"
    WHEN TIME between "12:01:00" AND "16:00:00" THEN "AFTERNOON"
    ELSE "EVENING"
END)AS TIME_OF_DAY
FROM SALES;
ALTER TABLE SALES ADD COLUMN TIME_OF_DAY VARCHAR(100);

UPDATE SALES 
SET TIME_OF_DAY=(
CASE 
	WHEN TIME BETWEEN "00:00:00" AND "12:00:00" THEN "MORNING"
	WHEN TIME BETWEEN "12:01:00" AND "16:00:00" THEN "AFTERNOON"
	ELSE "EVENING"
END);
SELECT*FROM SALES ;

SELECT TIME_OF_DAY, COUNT(*)AS TOTAL_SALES  FROM SALES 
WHERE DAY_NAME="MONDAY"
GROUP BY TIME_OF_DAY;

-- Q2 Which of the customer types brings the most revenue? 
SELECT CUSTOMER_TYPE , ROUND(SUM(TOTAL),2) AS TOTAL_SALES FROM SALES 
GROUP BY CUSTOMER_TYPE ORDER BY TOTAL_SALES DESC LIMIT 1 ;

-- Q3 Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT CITY ,MAX(VAT) AS VAT FROM SALES 
GROUP BY CITY ORDER BY VAT DESC;

-- Q4 Which customer type pays the most in VAT? 
SELECT CUSTOMER_TYPE, SUM(VAT)AS VAT FROM SALES 
GROUP BY CUSTOMER_TYPE ORDER BY VAT DESC;
-- ==========================================================================================================================================================================================================
-- ------------------------------------------------------------------------------------------CUSTOMER-------------------------------------------------------------------------------------------------------
-- Q1 How many unique customer types does the data have?
SELECT DISTINCT CUSTOMER_TYPE FROM SALES ;

-- Q2 How many unique payment methods does the data have?
SELECT DISTINCT PAYMENT_METHOD FROM SALES ;

-- Q3 What is the most common customer type?
SELECT CUSTOMER_TYPE , COUNT(*)AS TOTAL_COUNT FROM  SALES 
GROUP BY CUSTOMER_TYPE ORDER BY TOTAL_COUNT DESC LIMIT 1 ;

-- Q4 Which customer type buys the most?
SELECT CUSTOMER_TYPE , COUNT(*) FROM SALES 
GROUP BY CUSTOMER_TYPE;

-- Q5 What is the gender of most of the customers?
SELECT GENDER , COUNT(*) FROM SALES 
GROUP BY GENDER  ORDER BY COUNT(*) DESC ;

-- Q6 What is the gender distribution per branch?
SELECT GENDER , COUNT(*) AS TOTAL_CNT  FROM SALES 
WHERE BRANCH = "C"
GROUP BY GENDER ORDER BY TOTAL_CNT DESC ;

-- Q7 Which time of the day do customers give most ratings?
SELECT TIME_OF_DAY , ROUND( AVG(RATING),2) AS AVG_RATING FROM SALES
GROUP BY TIME_OF_DAY ORDER BY AVG_RATING  DESC ;

-- Q8 Which time of the day do customers give most ratings per branch?
SELECT ROUND(AVG(RATING),2) AS AVG_RATING ,TIME_OF_DAY FROM  SALES
WHERE BRANCH="C"
GROUP  BY TIME_OF_DAY ORDER BY AVG_RATING DESC   ;

-- Q9 Which day oF the week has the best avg ratings?
SELECT DAY_NAME , ROUND(AVG (RATING),2) AS AVG_RATING FROM SALES
GROUP BY DAY_NAME ORDER BY AVG_RATING DESC LIMIT 1 ;

-- Q10 Which day of the week has the best average ratings per branch?
SELECT  DAY_NAME , ROUND(AVG(RATING),2)AS AVG_RATING FROM SALES
WHERE BRANCH = "B"
GROUP BY DAY_NAME ORDER BY AVG_RATING DESC LIMIT 1
 ;










