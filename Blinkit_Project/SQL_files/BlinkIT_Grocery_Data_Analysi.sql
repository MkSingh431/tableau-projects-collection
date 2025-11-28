CREATE DATABASE Blinkit;

DROP TABLE IF EXISTS blinkit_grocery_data;

CREATE TABLE blinkit_grocery_data(
	Item_Fat_Content VARCHAR(15),
    Item_Identifier VARCHAR(15),
    Item_type VARCHAR(21),
	Outlet_Establishment_Year YEAR,
    Outlet_Identifier VARCHAR(21),
    Outlet_Location_Type VARCHAR(20),
    Outlet_Size VARCHAR(50),
    Outlet_Type	VARCHAR(20),
    Item_Visibility	VARCHAR(17),
    Item_Weight	FLOAT(11),
    Sales FLOAT(8),
    Rating INT
	);

-- Loaded data manually
	-- LOAD DATA LOCAL INFILE 'C:\Users\malli\Downloads\BlinkIT-Grocery-Data.csv'
	-- INTO TABLE blinkit_grocery_data
	-- FIELDS TERMINATED BY ','
	-- LINES TERMINATED BY '\n'
	-- IGNORE 1 ROWS;
---------------------------------------------------------------------------------------------

SELECT * FROM blinkit_grocery_data;
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
/* Sales & Revenue Analysis */
-- Task - 1:- Find total sales for each outlet and sort by descending order of revenue.
SELECT 
	Outlet_Identifier, 
    SUM(Sales) AS Total_Sales
FROM blinkit_grocery_data
GROUP BY Outlet_Identifier
ORDER BY Total_Sales DESC;
--------------------------------------------------------------------------------------------------
-- Task - 2:- List the top 5 items with the highest sales across all outlets.

SELECT 
	DISTINCT(Item_type),
    SUM(Sales) AS Total_Sales
FROM blinkit_grocery_data
GROUP BY Item_type
ORDER BY Total_Sales DESC
LIMIT 5;
--------------------------------------------------------------------------------------------------
-- Task -3. Calculate **average sales** per `Item Type` for each `Outlet Type`.
SELECT
	Item_type,
    Outlet_Type,
    AVG(Sales) AS Average_Sales
FROM blinkit_grocery_data
GROUP BY Item_type, Outlet_Type
ORDER BY Outlet_Type, Average_Sales DESC;
----------------------------------------------------------------------------------------------------
-- Task -4. Find the **outlet with the highest revenue** for items of "Fruits and Vegetables".

SELECT 
	Outlet_Identifier,
	SUM(sales) AS Highest_Revenue
FROM blinkit_grocery_data
WHERE Item_type LIKE 'Fruits and Vegetables'
GROUP BY Outlet_Identifier
ORDER BY Highest_Revenue DESC
LIMIT 1;
----------------------------------------------------------------------------------------------------
-- Task -5. Determine the **contribution of each `Item Fat Content`** type towards total sales.
	-- Checking for unique types of fat content
SELECT DISTINCT Item_Fat_Content, COUNT(Item_Fat_Content) FROM blinkit_grocery_data GROUP BY Item_Fat_Content;
	-- found ----> Regular = 2388, Low Fat = 4306, LF = 260, reg = 106
    -- time to modify LF to Low Fat & reg to regular OR BETTER TO CREATE A VIEW FOR THIS INSTEAD OF MODIFYING THE data set
	CREATE VIEW standardized_grocery_data AS
	SELECT *,
		CASE 
			WHEN Item_Fat_Content = 'LF' THEN 'Low Fat'
            WHEN Item_Fat_Content = 'reg' THEN 'Regular'
            ELSE Item_Fat_Content
		END AS Item_Fat_Content_Unique
    FROM blinkit_grocery_data;
	-- Verifying the changes
	SELECT DISTINCT Item_Fat_Content_Unique, COUNT(Item_Fat_Content_Unique) FROM standardized_grocery_data GROUP BY Item_Fat_Content_Unique;
SELECT 
	Item_Fat_Content_Unique,
    SUM(Sales) AS Total_Sales
FROM standardized_grocery_data
GROUP BY Item_Fat_Content_Unique 
ORDER BY Total_Sales DESC;
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
/* Outlet Performance */
-- Task -6. Identify the **average sales per outlet size** (Small, Medium, High).
SELECT 
	Outlet_Size,
    AVG(Sales) AS Average_sales_per_outlet_size,
    COUNT(*) AS Number_of_Outlets
FROM blinkit_grocery_data
WHERE Outlet_Size IS NOT NULL
GROUP BY Outlet_Size
ORDER BY Average_sales_per_outlet_size DESC;
--------------------------------------------------------------------------------
-- Task -7. Find the **oldest and newest outlets** in the dataset based on the `Outlet Establishment Year`.
(SELECT 
    Outlet_Identifier,
    Outlet_Establishment_Year AS Outlet_Year,
    'Oldest' AS Outlet_Type
FROM blinkit_grocery_data
ORDER BY Outlet_Establishment_Year ASC
LIMIT 1) 
UNION
(SELECT 
    Outlet_Identifier,
    Outlet_Establishment_Year AS Outlet_Year,
    'Newest' AS Outlet_Type
FROM blinkit_grocery_data
ORDER BY Outlet_Establishment_Year DESC
LIMIT 1);
------------------------------------------------------------------------------
-- Task -8. Compare **sales performance** across different `Outlet Location Type` (Tier 1, 2, 3).
SELECT 
	Outlet_Location_Type,
    SUM(Sales) AS Sales_Performance
FROM blinkit_grocery_data
GROUP BY Outlet_Location_Type
ORDER BY Sales_Performance DESC;
--------------------------------------------------------------------------------
-- Task -9. Rank the outlets based on **total sales** within each `Outlet Type`.
SELECT 
	RANK()  OVER (ORDER BY SUM(SALES) DESC) AS Outlet_Ranking,
    Outlet_Type,
    Outlet_Identifier,
    SUM(Sales) AS Total_Sales
FROM blinkit_grocery_data
GROUP BY Outlet_Identifier, Outlet_Type
ORDER BY  Outlet_Ranking, Outlet_Type;
--------------------------------------------------------------------------------
-- Task -10. Identify the **outlet where item visibility is the lowest** on average.
SELECT 
    Outlet_Identifier,
	AVG(Item_Visibility) AS Avg_Item_Visibility
FROM blinkit_grocery_data
GROUP BY Outlet_Identifier
ORDER BY Avg_Item_Visibility
LIMIT 1;
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
/* Item-Level Insights */
-- Task -11. Calculate **average sales** and **average rating** for each `Item Type`.
SELECT 
	Item_type,
    AVG(Sales) AS Average_Sales,
    AVG(Rating) AS Average_Rating
FROM blinkit_grocery_data
GROUP BY Item_type
ORDER BY Average_Sales DESC, Average_Rating DESC;
--------------------------------------------------------------------------------
-- Task -12. Identify items with **missing `Item Weight`** and determine their `Item Type` distribution.
SELECT 
    Item_type,
    COUNT(Item_Identifier) AS Missing_Weight_Count
FROM blinkit_grocery_data
WHERE Item_Weight IS NULL
GROUP BY Item_type;
---------------------------------------------------------------------------------
-- Task -13. For each `Item Fat Content`, find the **average visibility and sales**
SELECT
	Item_Fat_Content_unique,
	AVG(Item_Visibility) AS Average_Item_Visibility,
    AVG(Sales) AS Average_Sales
FROM standardized_grocery_data
GROUP BY Item_Fat_Content_unique 
ORDER BY Average_Item_Visibility DESC, Average_Sales DESC;
----------------------------------------------------------------------------------
-- Task -14. Determine which **Item Type** contributes the most to total sales.
SELECT 
	Item_type,
    SUM(Sales) AS Total_Sales
FROM blinkit_grocery_data
GROUP BY Item_type
ORDER BY Total_Sales DESC
LIMIT 1;
---------------------------------------------------------------------------------
-- Task -15. Calculate the **percentage of items** having "Low Fat" compared to "Regular" fat content.
SELECT 
	COUNT(CASE WHEN Item_Fat_Content_Unique = 'Low Fat'THEN  1 END) AS Low_Fat_Items_Count,
	COUNT(CASE WHEN Item_Fat_Content_Unique = 'Regular'THEN 1 END) AS Regular_Fat_Items_Count,
    ROUND((COUNT(CASE WHEN Item_Fat_Content_Unique = 'Low Fat'THEN  1 END) / 
    COUNT(CASE WHEN Item_Fat_Content_Unique = 'Regular'THEN 1 END)) * 100, 2) AS Low_Fat_Items_percentage_Over_Regular_Fat
FROM standardized_grocery_data;





		
	













