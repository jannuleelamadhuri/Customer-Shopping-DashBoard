select * from customer_shopping;
SELECT TOP 5 * FROM customer_shopping;
-- Q1. Total revenue by male vs female
SELECT Gender, SUM([Purchase Amount (USD)]) AS revenue
FROM customer_shopping GROUP BY Gender;

-- Q2. Customers used discount but spent more than avg
SELECT [Customer ID], [Purchase Amount (USD)]
FROM customer_shopping
WHERE [Discount Applied] = 'Yes' 
AND [Purchase Amount (USD)] >= (SELECT AVG([Purchase Amount (USD)]) FROM customer_shopping);

-- Q3. Top 5 products with highest avg review rating
SELECT TOP 5 [Item Purchased], ROUND(AVG(CAST([Review Rating] AS FLOAT)),2) AS avg_rating
FROM customer_shopping GROUP BY [Item Purchased] ORDER BY avg_rating DESC;

-- Q4. Avg Purchase Amount between Standard and Express
SELECT [Shipping Type], ROUND(AVG(CAST([Purchase Amount (USD)] AS FLOAT)),2) AS avg_amount
FROM customer_shopping WHERE [Shipping Type] IN ('Standard','Express') GROUP BY [Shipping Type];

-- Q5. Subscribed vs Non-subscribed
SELECT [Subscription Status], COUNT([Customer ID]) AS total_customers, ROUND(AVG(CAST([Purchase Amount (USD)] AS FLOAT)),2) AS avg_spend
FROM customer_shopping GROUP BY [Subscription Status];

-- Q6. Which 5 products have highest % of purchases with discounts
SELECT TOP 5 [Item Purchased], ROUND(100.0 * SUM(CASE WHEN [Discount Applied]='Yes' THEN 1 ELSE 0 END)/COUNT(*),2) 
AS discount_rate
FROM customer_shopping GROUP BY [Item Purchased] ORDER BY discount_rate DESC;

-- Q7. Segment customers into New, Returning, and Loyal
WITH c AS (SELECT CASE WHEN [Previous Purchases]=1 
THEN 'New' WHEN [Previous Purchases] BETWEEN 2 AND 10 THEN 'Returning' ELSE 'Loyal' END AS seg 
FROM customer_shopping) 
SELECT seg, COUNT(*) AS cnt FROM c GROUP BY seg;

-- Q8. Top 3 most purchased products within each category
WITH item_counts AS (SELECT Category, [Item Purchased], 
COUNT([Customer ID]) AS total_orders, ROW_NUMBER() OVER (PARTITION BY Category 
ORDER BY COUNT([Customer ID]) DESC) AS item_rank FROM customer_shopping 
GROUP BY Category, [Item Purchased])
SELECT * FROM item_counts WHERE item_rank <= 3;

-- Q9. Are repeat buyers likely to subscribe?
SELECT [Subscription Status], COUNT([Customer ID]) AS repeat_buyers FROM customer_shopping WHERE [Previous Purchases] > 5 GROUP BY [Subscription Status];

-- Q10. Revenue contribution of each age group
SELECT CASE WHEN Age BETWEEN 18 AND 30 
THEN '18-30' WHEN Age BETWEEN 31 AND 50 
THEN '31-50' ELSE '51+' END AS age_group, 
SUM([Purchase Amount (USD)]) AS total_revenue 
FROM customer_shopping GROUP BY CASE WHEN Age BETWEEN 18 AND 30 
THEN '18-30' WHEN Age BETWEEN 31 AND 50 THEN '31-50' ELSE '51+' 
END ORDER BY total_revenue DESC;