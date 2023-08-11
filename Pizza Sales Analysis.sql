-- First query
SELECT
  *
FROM pizza_sales

-- KPIs --
-- Revenue
SELECT
  SUM(pizza_sales.quantity * pizza_sales.unit_price) AS REVENUE
FROM pizza_sales

-- Alternative solution to get Revenue
SELECT
  SUM(total_price) AS Revenue
FROM pizza_sales

-- Average order value
SELECT
  SUM(total_price) / COUNT(DISTINCT order_id) AS Avg_Order_Value
FROM pizza_sales

-- Total quantity sold
SELECT
  SUM(quantity) AS Total_Quantity_Sold
FROM pizza_sales

-- Total orders pLaced
SELECT
  COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales

-- Average quantity per order --
-- Using CTE just for flex
WITH Total_Quantity_Sold
AS (SELECT
  SUM(quantity) AS Total_Quantity_Sold
FROM pizza_sales),
Total_Order
AS (SELECT
  COUNT(DISTINCT order_id) AS Total_Order
FROM pizza_sales)

SELECT
  Total_Quantity_Sold / Total_Order AS Avg_Qty_per_Order
FROM Total_Quantity_Sold,
     Total_Order

-- Using a simplified query and casted to get decimal values
SELECT
  CAST(CAST(SUM(quantity) AS decimal(10, 2))
  / CAST(COUNT(DISTINCT order_id) AS decimal(10, 2)) AS decimal(10, 2)) AS Avg_Qty_Per_Order
FROM pizza_sales

-- Number of orders per day of the week
SELECT
  DATENAME(WEEKDAY, order_date) AS Day_Of_Week,
  COUNT(DISTINCT order_id) Order_Count
FROM pizza_sales
GROUP BY DATENAME(WEEKDAY, order_date)
ORDER BY 2 DESC

-- number of order per month of the year
SELECT
  DATENAME(MONTH, order_date) AS Month,
  COUNT(DISTINCT order_id) Order_Count
FROM pizza_sales
GROUP BY DATENAME(MONTH, order_date)
ORDER BY 2 DESC

-- hourly order trend
SELECT
  DATENAME(HOUR, order_time) AS Month,
  COUNT(DISTINCT order_id) Order_Count
FROM pizza_sales
GROUP BY DATENAME(HOUR, order_time)
ORDER BY 2 DESC

-- Percentage of sales per category; the where clause can be used to break down the result by month 
-- different functions to return the month of January can be used as in the query
SELECT
  pizza_category,
  SUM(total_price) AS Revenue,
  SUM(total_price) * 100 / (SELECT
    SUM(total_price)
  FROM pizza_sales
  --where month(order_date)= 1
  )
  AS Percentage_Of_Total_Sales
FROM pizza_sales
--where DATENAME(MONTH, order_date) = 'January'
GROUP BY pizza_category

-- Percentage of sales per size; the where clause can be used to break down the result by month 
-- different functions to return the month of January can be used as in the query
SELECT
  pizza_size,
  CAST(SUM(total_price) AS decimal(10, 2)) AS Revenue,
  CAST(SUM(total_price) * 100 / (SELECT
    SUM(total_price)
  FROM pizza_sales
  --where month(order_date)= 1
  )
  AS decimal(10, 2)) AS Percentage_Of_Total_Sales
FROM pizza_sales
--where DATENAME(MONTH, order_date) = 'January'
GROUP BY pizza_size
ORDER BY Percentage_Of_Total_Sales DESC

-- top 5 sellers by revenue, total quantity and total orders --
SELECT TOP 5
  pizza_name,
  SUM(total_price) AS Revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY 2 DESC
-- by total quantity
SELECT TOP 5
  pizza_name,
  SUM(quantity) AS Total_Quantity
FROM pizza_sales
GROUP BY pizza_name
ORDER BY 2 DESC
-- total orders
SELECT TOP 5
  pizza_name,
  COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY pizza_name
ORDER BY 2 DESC

-- Bottom 5 sellers by revenue, total quantity and total orders --
SELECT TOP 5
  pizza_name,
  SUM(total_price) AS Revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY 2 ASC
-- by total quantity
SELECT TOP 5
  pizza_name,
  SUM(quantity) AS Total_Quantity
FROM pizza_sales
GROUP BY pizza_name
ORDER BY 2 ASC
-- total orders
SELECT TOP 5
  pizza_name,
  COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY pizza_name
ORDER BY 2 ASC