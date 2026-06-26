CREATE DATABASE financial_analytics;
USE financial_analytics;
CREATE TABLE stocks (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    Name                VARCHAR(100),
    MarketCap           DECIMAL(12,2),
    Sales               DECIMAL(12,2),
    Market_Cap_Category VARCHAR(50),
    Sales_Qrt_Category  VARCHAR(50)
);
SELECT * FROM stocks;
--  Add the P/S Ratio Column
SET SQL_SAFE_UPDATES = 0;

UPDATE stocks 
SET PS_Ratio = ROUND(MarketCap / NULLIF(Sales, 0), 2);

SELECT Name, MarketCap, Sales, PS_Ratio 
FROM stocks 
LIMIT 100;
-- Top 10 Companies by Market Cap
SELECT Name, MarketCap
FROM stocks
ORDER BY MarketCap DESC
LIMIT 10;
-- Average Market Cap & Sales per Category
SELECT Market_Cap_Category,
       ROUND(AVG(MarketCap), 2) AS Avg_MarketCap,
       ROUND(AVG(Sales), 2)     AS Avg_Sales,
       COUNT(*)                 AS Total_Stocks
FROM stocks
GROUP BY Market_Cap_Category
ORDER BY Avg_MarketCap DESC;
--  Large Cap Companies with Low Sales (Red Flags)
SELECT Name, MarketCap, Sales, Sales_Qrt_Category
FROM stocks
WHERE Market_Cap_Category = 'Large Cap'
  AND Sales_Qrt_Category IN ('Low Sales', 'Very Low Sales')
ORDER BY MarketCap DESC;
-- Top 10 Most Overvalued by P/S Ratio
SELECT Name, MarketCap, Sales, PS_Ratio
FROM stocks
ORDER BY PS_Ratio DESC
LIMIT 10;
-- Total Market Cap by Both Category Columns (Cross Tab)
SELECT Market_Cap_Category,
       Sales_Qrt_Category,
       ROUND(SUM(MarketCap), 2) AS Total_MarketCap,
       COUNT(*)                 AS Stocks
FROM stocks
GROUP BY Market_Cap_Category, Sales_Qrt_Category
ORDER BY Total_MarketCap DESC;
-- Stocks Above the Overall Average Market Cap
SELECT Name, MarketCap, Market_Cap_Category
FROM stocks
WHERE MarketCap > (SELECT AVG(MarketCap) FROM stocks)
ORDER BY MarketCap DESC;
--  Rank Stocks Within Each Category (Window Function)
SELECT Name, Market_Cap_Category, MarketCap,
       RANK() OVER (
           PARTITION BY Market_Cap_Category
           ORDER BY MarketCap DESC
       ) AS Rank_In_Category
FROM stocks
ORDER BY Market_Cap_Category, Rank_In_Category;
-- Market Cap Quartiles Across All Stocks
SELECT Name, MarketCap,
       NTILE(4) OVER (ORDER BY MarketCap) AS Quartile
FROM stocks
ORDER BY MarketCap DESC;
-- Companies Where Sales Exceed Market Cap
SELECT 
    Name,
    MarketCap,
    Sales,
    ROUND(Sales - MarketCap, 2) AS Sales_Excess
FROM
    stocks
WHERE
    Sales > MarketCap
ORDER BY Sales_Excess DESC;
--  Full Category Summary Dashboard
SELECT Market_Cap_Category,
       COUNT(*)                    AS Total_Stocks,
       ROUND(SUM(MarketCap), 0)    AS Total_MarketCap,
       ROUND(AVG(MarketCap), 0)    AS Avg_MarketCap,
       ROUND(MIN(MarketCap), 0)    AS Min_MarketCap,
       ROUND(MAX(MarketCap), 0)    AS Max_MarketCap,
       ROUND(AVG(Sales), 0)        AS Avg_Sales
FROM stocks
GROUP BY Market_Cap_Category
ORDER BY Total_MarketCap DESC;