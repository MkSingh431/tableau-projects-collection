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
----------------------------------------------------------------------------------------------
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
---------------------------------------------------------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
/* Rating Analysis */
-----------------------------------------------------------------------------------------------------------------
-- Task -16. List the **outlets with the highest average item ratings**.
SELECT 
	Outlet_Identifier,
    AVG(Rating) AS Highest_average
FROM blinkit_grocery_data
GROUP BY Outlet_Identifier
ORDER BY Highest_average DESC
LIMIT 1;
---------------------------------------------------------------------------------------------------------------
-- Task -17. Identify items with a **rating of 5.0** and analyze their total sales contribution.
	-- CHECKING FOR UNIQUE RATINGS IN RATING COLOUMN
	SELECT DISTINCT rating,  COUNT(Rating) AS Ratings_count FROM blinkit_grocery_data GROUP BY Rating;
SELECT 
	Item_Identifier,
    SUM(Sales) AS Total_Sales
FROM blinkit_grocery_data
WHERE Rating = 5
GROUP BY Item_Identifier
ORDER BY Total_Sales DESC;

	-- IDENTIFYING THE PERCENTAGE FOR THE SAME TASK
	SELECT
		SUM(Sales) AS Sales_with_perfect_rating,
        ROUND(SUM(Sales) / (SELECT SUM(Sales) FROM blinkit_grocery_data) * 100, 2) AS Percentage_Sales_with_perfect_rating
	FROM blinkit_grocery_data
    WHERE Rating = 5;
------------------------------------------------------------------------------------------------------------------
-- Task -18. Determine the **average sales and visibility** of items with different ratings.
SELECT
	AVG(Sales) AS Average_Sales,
    AVG(Item_Visibility) AS Average_Item_Visibility,
    Rating
FROM blinkit_grocery_data
GROUP BY Rating;
	-- Same query with stddev
		SELECT
			AVG(Sales) AS Average_Sales,
			STDDEV(Sales) AS Sales_StdDev,
			AVG(Item_Visibility) AS Average_Item_Visibility,
			STDDEV(Item_Visibility) AS Item_Visibility_StdDev,
			Rating
		FROM blinkit_grocery_data
		GROUP BY Rating;
    -- Same query with count
		SELECT
			AVG(Sales) AS Average_Sales,
			AVG(Item_Visibility) AS Average_Item_Visibility,
            COUNT(*) AS Total_Count,
			Rating
		FROM blinkit_grocery_data
		GROUP BY Rating;
---------------------------------------------------------------------------------------------------------
-- Task -19. Determine the Items, outlet size, location, established year with ratings less than 2.5 and sales less than avg sales.
	-- This analysis helps to identify poor performing item type, otlet size, location with sales less than avg sales 
WITH Avg_Sales AS(
	SELECT 
		AVG(Sales) AS Avg_Sales 
	FROM blinkit_grocery_data)
    
SELECT
	Item_type,
    Outlet_Size,
    Outlet_Type,
    Outlet_Location_Type,
    Outlet_Establishment_Year,
    Sales,
    Rating
FROM blinkit_grocery_data
CROSS JOIN Avg_Sales
WHERE Rating <= 2.5 AND Sales < Avg_Sales
ORDER BY Rating DESC, Sales DESC;
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
/* Operational Analysis */
-- Task -20. Find the **average item weight** for each `Item Type` and sort it in descending order.
SELECT 
	Item_type,
    AVG(Item_Weight) AS Average_Item_Weight
FROM blinkit_grocery_data
GROUP BY Item_type
ORDER BY Average_Item_Weight DESC;
------------------------------------------------------------------------------------------------------------
-- Task -21. Identify if there is a relationship between **item visibility** and sales performance (e.g., higher visibility leading to higher sales).
	-- Categorize visibility into ranges to observe trends
    WITH Visibility_Categories AS(
								SELECT 
									CASE 
										WHEN Item_Visibility < 0.05 THEN 'Very Low'
										WHEN Item_Visibility >= 0.05 AND Item_Visibility < 0.1 THEN 'Low'
										WHEN Item_Visibility >=0.1 AND Item_Visibility <0.2 THEN 'Medium'
										ELSE 'High'
									END AS Visibility_Categories,
                                    Sales
								FROM blinkit_grocery_data
                                 )
	-- -- Calculate average sales for each visibility range
	SELECT 
		Visibility_Categories,
        AVG(Sales) AS Average_Sales,
        COUNT(*) AS Item_count
    FROM Visibility_Categories
    GROUP BY Visibility_Categories
    ORDER BY Average_Sales DESC;
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
/* **Advanced and Tricky Questions** */ 
---------------------------------------------------------------------------------------
-- TASK -1. Find the top 3 outlets where the sales of "Health and Hygiene" items contribute the most to their total sales.**
SELECT
	Outlet_Identifier,
    Item_type,
    SUM(Sales) AS Health_and_Hygiene_Total_sales
FROM blinkit_grocery_data
-- WHERE Item_type LIKE 'Health and Hygiene'
GROUP BY Outlet_Identifier, Item_type
ORDER BY Health_and_Hygiene_Total_sales DESC
LIMIT 3;
--------------------------------------------------------------------------------------------------------------------------
-- TASK -2. Determine the top 5 items that are the most visible (highest average `Item_Visibility`) but have below-average sales.
-- Insight: Identify items that are displayed prominently but don’t convert to sales.
-- Categorize visibility into ranges to observe trends and create a view
    CREATE VIEW Visibility_Categories AS(
								SELECT
									*,
									CASE 
										WHEN Item_Visibility < 0.05 THEN 'Very Low'
										WHEN Item_Visibility >= 0.05 AND Item_Visibility < 0.1 THEN 'Low'
										WHEN Item_Visibility >=0.1 AND Item_Visibility <0.2 THEN 'Medium'
										ELSE 'High'
									END AS Visibility_Categories_Column
								FROM blinkit_grocery_data
                                 );
	
	WITH Average_Sales AS(
						 SELECT AVG(Sales) AS Avg_Sales
						 FROM blinkit_grocery_data
						 )

SELECT 
    V.Item_Identifier,
    V.Item_type,
    AVG(V.Item_Visibility) AS Avg_Visibility,
    SUM(V.Sales) AS Total_Sales,
    V.Visibility_Categories_Column
FROM Visibility_Categories V
CROSS JOIN Average_Sales 
WHERE V.Visibility_Categories_Column = 'High'
GROUP BY V.Item_Identifier, V.Item_type, V.Visibility_Categories_Column
HAVING Total_Sales < (SELECT Avg_Sales FROM Average_Sales) -- Below-average sales condition
ORDER BY Avg_Visibility DESC
LIMIT 5;
---------------------------------------------------------------------------------------------
-- TASK 3. Compare the sales contribution of each `Outlet_Type` for "Frozen Foods" and "Dairy" categories.**
-- Insight: Evaluate the strengths of different outlet types for specific categories.

SELECT DISTINCT Item_type, COUNT(Item_type) FROM blinkit_grocery_data GROUP BY Item_type ORDER BY Item_type ASC; -- Cheking for unique item types

SELECT 
	Outlet_Type,
    Item_type,
    SUM(Sales) AS Total_sales
FROM blinkit_grocery_data
WHERE Item_type = 'Frozen Foods' OR Item_type = 'Dairy'
GROUP BY Outlet_Type, Item_type
ORDER BY Total_sales DESC, Item_type;
----------------------------------------------------------------------------------------------------------------------
-- TASK -4. Identify outlets where more than 50% of the items sold are "Low Fat".**
-- Insight: Determine which outlets prioritize health-conscious items.
WITH Low_Fat_Items AS (
					  SELECT 
						Outlet_Identifier, 
						Outlet_Location_Type, 
						Outlet_Size, 
						Outlet_Type,
                        Item_Fat_Content_Unique,
                        SUM(Sales) AS Total_Low_Fat_Sales
					FROM standardized_grocery_data
                    WHERE Item_Fat_Content_Unique = 'Low Fat'
                    GROUP BY Outlet_Identifier, Outlet_Location_Type, Outlet_Size, Outlet_Type, Item_Fat_Content_Unique
                      ),
Total_Sales_cte AS (
					SELECT Outlet_Identifier,
						   SUM(Sales) AS Totla_Sales
                    FROM standardized_grocery_data
                    GROUP BY Outlet_Identifier
					)
SELECT 
	Outlet_Identifier, 
    Outlet_Location_Type, 
    Outlet_Size, 
    Outlet_Type,
    Item_Fat_Content_Unique,
    Total_Low_Fat_Sales,
    (Total_Low_Fat_Sales / tsc.Totla_Sales)*100 AS Percentage_Low_Fat_Items_Sold
FROM Low_Fat_Items 
JOIN Total_Sales_cte tsc USING (Outlet_Identifier)
WHERE (Total_Low_Fat_Sales / tsc.Totla_Sales)* 100 > 50
ORDER BY Percentage_Low_Fat_Items_Sold DESC;
----------------------------------------------------------------------------------------------
-- TASK -5. Calculate the average sales per year for each outlet, considering its establishment year.**
-- Insight: Compare newer outlets' performance with older ones.
SELECT
	Outlet_Identifier,
    Outlet_Establishment_Year,
    (CASE 
		WHEN YEAR(CURDATE()) - Outlet_Establishment_Year = 0 THEN 1
        ELSE YEAR(CURDATE()) - Outlet_Establishment_Year
      END)  AS Years_Of_Operation,
	SUM(Sales) AS Total_Sales,
    SUM(Sales) / (CASE
					WHEN YEAR(CURDATE()) - Outlet_Establishment_Year = 0 THEN 1
                    ELSE YEAR(CURDATE()) - Outlet_Establishment_Year
				  END) AS Total_Sales_Per_Year
	
FROM blinkit_grocery_data
GROUP BY Outlet_Identifier, Outlet_Establishment_Year
ORDER BY Total_Sales_Per_Year DESC;
---------------------------------------------------------------------
-- TASK -6. Determine the correlation between `Item_Visibility` and `Sales` for different `Outlet_Types`.**
-- Insight: Investigate whether better visibility leads to higher sales in various outlet types.
/* analyzing by checking average visibility & sales in varius outlet types */
SELECT
	Outlet_Type,
    AVG(Item_Visibility) AS Avg_Item_Visibility,
    AVG(Sales) AS Avg_Sales
FROM blinkit_grocery_data
GROUP BY Outlet_Type
ORDER BY Avg_Item_Visibility DESC;

/* analyzing by checking Pearson_Correlation between visibility & sales in varius outlet types */
SELECT
	Outlet_Type,
    (COUNT(*) * SUM(Item_Visibility * Sales) - (SUM(Item_Visibility * Sales)) / 
    (SQRT(
			(COUNT(*) * (SUM(Item_Visibility * Item_Visibility)) - (SUM(Item_Visibility * Item_Visibility))) *
            (COUNT(*) * (SUM(Sales * Sales)) - (SUM(Sales * Sales)))))) AS Pearson_Correlation 
FROM blinkit_grocery_data
GROUP BY Outlet_Type
ORDER BY Pearson_Correlation DESC;
-------------------------------------------------------------------------------------------------------------
-- TASK -7. Find the most profitable `Item_Type` for each `Outlet_Size`.**
-- Insight: Determine which product categories perform best depending on outlet size.
WITH Avg_sales AS(
	SELECT AVG(Sales) AS Avg_Sales, Outlet_Size
    FROM blinkit_grocery_data
    GROUP BY Outlet_Size)
SELECT
	b.Item_type AS Profitable_Item_Type,
    b.Outlet_Size,
    SUM(b.Sales) AS Total_Sales
FROM blinkit_grocery_data b
JOIN Avg_sales a USING (Outlet_Size)
WHERE b.Rating > 3.75 AND b.Sales > a.Avg_sales
GROUP BY b.Outlet_Size, b.Item_type
ORDER BY b.Outlet_Size, Total_Sales DESC;
---------------------------------------------------------------------------------------
-- TASK -8. Identify the outlets where sales consistently fall below the median sales value of all outlets.
-- Insight: Focus on underperforming outlets.
WITH Outlet_Sales AS(
					SELECT
						Outlet_Identifier,
                        SUM(Sales) AS Total_Sales
                    FROM blinkit_grocery_data
                    GROUP BY Outlet_Identifier
                    ),
Median_Sales AS (
				SELECT
                    CASE
						WHEN COUNT(*) % 2 = 1 THEN
							(SELECT Total_Sales FROM (
													SELECT Total_Sales, ROW_NUMBER() OVER (ORDER BY Total_Sales) AS Row_Num FROM Outlet_Sales)
                            AS Ranked WHERE (COUNT(*) + 1) / 2)
						ELSE
							(SELECT AVG(Total_Sales) FROM (
													SELECT Total_Sales, ROW_NUMBER() OVER (ORDER BY Total_Sales) AS Row_Num FROM Outlet_Sales)
							AS Ranked WHERE Row_Num IN (COUNT(*)/2, (COUNT(*) / 2) + 1))
					END AS Median_Sales
                FROM Outlet_Sales
				)
SELECT 
	o.Outlet_Identifier,
    o.Total_Sales
FROM Outlet_Sales o
CROSS JOIN Median_Sales m
WHERE O.Total_Sales < m.Median_Sales
ORDER BY o.Total_Sales;
-----------------------------------------------------------------------------------------------------------
-- TASK -10. For each outlet, calculate the percentage of items with a rating of 4.0 or higher.**
-- Insight: Assess product satisfaction by location.
WITH Total_Items_per_Outlet AS(
							SELECT
                                Outlet_Identifier,
                                COUNT(*) AS Total_items_Count_Per_outlet
                            FROM blinkit_grocery_data
                            GROUP BY Outlet_Identifier),
Total_High_Rated_items_per_outlet AS (
							SELECT
								Outlet_Identifier,
                                COUNT(*) AS High_Rated_Items_Count_Per_Outlet
                            FROM blinkit_grocery_data
                            WHERE Rating >= 4
                            GROUP BY Outlet_Identifier)
SELECT 
	b.Outlet_Identifier,
    b.Outlet_Location_Type,
    b.Outlet_Size,
    b.Outlet_Type,
    ROUND((th.High_Rated_Items_Count_Per_Outlet * 100 / ti.Total_items_Count_Per_outlet), 2) AS High_Item_Rated_Percentage
FROM blinkit_grocery_data b
JOIN Total_Items_per_Outlet ti USING (Outlet_Identifier)
JOIN Total_High_Rated_items_per_outlet th USING (Outlet_Identifier)
GROUP BY b.Outlet_Identifier, b.Outlet_Location_Type, b.Outlet_Size, b.Outlet_Type
ORDER BY High_Item_Rated_Percentage DESC;
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
/* **Real-Life Scenarios** */
---------------------------------------------------------------------------------------------------------------
-- TASK -11. Which item types have the largest variation in sales across outlets?**
-- Insight: Identify items with inconsistent performance and investigate.
WITH Total_Sales_Per_Item_Outlet AS(
									SELECT
										Outlet_Identifier,
                                        Item_type,
                                        SUM(Sales) AS Total_sales
                                    FROM blinkit_grocery_data
                                    GROUP BY Outlet_Identifier,
                                        Item_type),
Sales_Statistics AS(
					SELECT
						Item_type,
                        AVG(Total_sales) AS Mean_sales,
                        STDDEV(Total_sales) AS stdv_Sales
					FROM Total_Sales_Per_Item_Outlet
                    GROUP BY Item_type)
SELECT
	s.Item_type,
    s.Mean_sales,
    s.stdv_Sales,
    (s.stdv_Sales / s.Mean_sales) *100 AS Coefficient_Sales
FROM Sales_Statistics s
ORDER BY Coefficient_Sales DESC;
------------------------------------------------------------------------
-- TASK -12. Determine which `Outlet_Size` has the largest proportion of "Regular" items in sales.**
-- Insight: Identify size preferences for regular-fat items.
WITH Total_Sales_For_Outlet_Size AS(
							SELECT 
								Outlet_Size,
								SUM(Sales) AS Total_Sales_For_Outlet
							FROM standardized_grocery_data
                            GROUP BY Outlet_Size),
Total_Sales_Of_Regular_Fat_For_Outlet_Size AS(
						SELECT
							Outlet_Size,
							SUM(Sales) AS Total_Sales_Of_Regular_Fat,
                            COUNT(*) AS Total_Regular_Item_Count
						FROM standardized_grocery_data
						WHERE Item_Fat_Content_Unique = 'Regular'
						GROUP BY Outlet_Size)
SELECT
	t.Outlet_Size,
    t.Total_Sales_For_Outlet,
    r.Total_Sales_Of_Regular_Fat,
    r.Total_Regular_Item_Count,
    ROUND((r.Total_Sales_Of_Regular_Fat * 100 / t.Total_Sales_For_Outlet), 3) AS Regular_Fat_Item_Sales_Prorportion
FROM Total_Sales_For_Outlet_Size t
JOIN Total_Sales_Of_Regular_Fat_For_Outlet_Size r 
USING(Outlet_Size)
ORDER BY Regular_Fat_Item_Sales_Prorportion DESC;
-------------------------------------------------------------------------------------------------------------------
-- TASK -13. Identify items that contribute to over 20% of total sales for their respective `Outlet_Identifier`.**
-- Insight: Highlight high-performing items specific to each outlet.
WITH Total_sales_For_Outlet AS (
				SELECT
					Outlet_Identifier,
                    SUM(Sales) AS Total_Sales_from_Each_Outlet
                FROM blinkit_grocery_data
                GROUP BY Outlet_Identifier),
--                 select * from Total_sales_For_Outlet;
Total_Sales_Per_Item AS(
			SELECT 
				Outlet_Identifier,
                Item_Identifier,
				Item_type,
				SUM(Sales) AS Item_Total_Sales
            FROM blinkit_grocery_data
            GROUP BY Outlet_Identifier,
                Item_Identifier,
				Item_type)     
SELECT
	tsi.Item_type,
    tsi.Item_Identifier,
    tso.Outlet_Identifier,
    tso.Total_Sales_from_Each_Outlet,
    tsi.Item_Total_Sales,
    (tsi.Item_Total_Sales * 100 / tso.Total_Sales_from_Each_Outlet)  AS Percentage_Total_Sales_from_Each_Outlet
FROM Total_Sales_Per_Item tsi
JOIN Total_sales_For_Outlet tso USING (Outlet_Identifier)
GROUP BY tsi.Item_type,
    tsi.Item_Identifier,
    tso.Outlet_Identifier,
    tso.Total_Sales_from_Each_Outlet,
    tsi.Item_Total_Sales
HAVING ((tsi.Item_Total_Sales / tso.Total_Sales_from_Each_Outlet) * 100) >=20;
-- No item is contributing more than 20%
-------------------------------------------------------------------------------------------------
-- TASK -14. Compare the average sales for "Tier 1" outlets vs. "Tier 3" outlets, broken down by `Item_Type`.**
-- Insight: Spot regional preferences for items.
SELECT
	Item_type,
    Outlet_Location_Type,
    ROUND(AVG(Sales), 3) AS Average_Sales
FROM blinkit_grocery_data
WHERE Outlet_Location_Type IN ('Tier 1', 'Tier 3')
GROUP BY Item_type,
    Outlet_Location_Type
ORDER BY Item_type,
    Outlet_Location_Type;
---------------------------------------------------------------------------------------
-- TASK -15. List the `Item_Identifiers` with the highest sales but the lowest average ratings.**
-- Insight: Identify popular but poorly-rated items.
WITH Total_Avg_Sales AS (
SELECT 	
		Item_Identifier,
		SUM(Sales) AS Total_Sales,
		AVG(Rating) AS avg_ratings
FROM blinkit_grocery_data
GROUP BY Item_Identifier)
SELECT 
	*
FROM Total_Avg_Sales
WHERE avg_ratings < 2.5
ORDER BY Total_Sales DESC;
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
/* **Challenging Analytical Questions** */
-----------------------------------------------------------------------------------------------------
-- TASK -16. Which outlets have their highest-rated items in the top 10% of sales but their lowest-rated items in the bottom 10%?**
-- Insight: Evaluate the consistency of product quality and popularity.
WITH Sales_Ranking AS (
					SELECT
						Item_Identifier,
                        Item_type,
                        Outlet_Identifier,
                        Rating,
                        Sales,
                        NTILE(100) OVER (ORDER BY Sales DESC) AS Sales_Percentile 
                    FROM blinkit_grocery_data),
Outlets_With_Highest_Rated_Items AS (
							SELECT
								Item_Identifier,
								Item_type,
								Outlet_Identifier,
								Rating,
								Sales
							FROM Sales_Ranking
                            WHERE Rating >= 4 AND Sales_Percentile <= 10),
Outlets_With_Lowest_Rated_Items AS (
							SELECT
								Item_Identifier,
								Item_type,
								Outlet_Identifier,
								Rating,
								Sales
							FROM Sales_Ranking
                            WHERE Rating <= 2.5 AND Sales_Percentile >= 90)
SELECT 
	h.Outlet_Identifier,
	h.Item_Identifier AS Highest_Rated_Item,
	h.Item_type AS Highest_Rated_Item_Type,
	h.Rating AS Highest_Item_Rating,
	h.Sales AS Highest_Item_Sales,
    l.Item_Identifier AS Lowest_Rated_Item,
	l.Item_type AS Lowest_Item_Type,
	l.Rating AS Lowest_Item_Rating,
	l.Sales AS Lowest_Item_Sales
FROM Outlets_With_Highest_Rated_Items h
JOIN Outlets_With_lowest_Rated_Items l USING (Outlet_Identifier)
ORDER BY h.Sales DESC, l.Sales;
--------------------------------------------------------------------------------------
-- 17. Find the items with the highest visibility-to-sales ratio.**
-- Insight: Identify products that may need better marketing to convert visibility into sales.
WITH Visibility_Sales_Table AS (
								SELECT
									Item_Identifier,
                                    Item_type,
                                    SUM(Sales) AS Total_Sales,
                                    SUM(Item_Visibility) AS Total_Visibility
								FROM blinkit_grocery_data
                                GROUP BY Item_Identifier, Item_type)
SELECT 
	*,
    ROUND(Total_Visibility / Total_Sales, 3) AS Visibility_Sales_Ratio
FROM Visibility_Sales_Table
ORDER BY Visibility_Sales_Ratio DESC
LIMIT 10;
---------------------------------------------------------------------------------
-- TASK -18. Calculate the total sales of all "Tier 2" outlets, excluding items with below-average visibility.**
-- Insight: Evaluate the impact of item placement on sales in Tier 2 locations.

WITH Below_AVG_Visibility AS (
							SELECT
								Outlet_Identifier,
                                AVG(Item_Visibility) AS Average_Visibility,
                                SUM(Sales) AS Total_Sales
                            FROM blinkit_grocery_data
                            GROUP BY Outlet_Identifier
                            )
SELECT
	B.Outlet_Identifier,
    Outlet_Location_Type,
    SUM(Sales) AS Total_Sales
FROM blinkit_grocery_data B
JOIN  Below_AVG_Visibility BAV USING (Outlet_Identifier)
WHERE Item_Visibility > BAV.Average_Visibility AND Outlet_Location_Type = 'Tier 2'
GROUP BY Outlet_Identifier, Outlet_Location_Type
ORDER BY Total_Sales DESC;
------------------------------------------------------------------------------------------
-- TASK -19. Identify item types where the highest sales come from outlets established after 2010.**
-- Insight: Discover trends in newer outlets.
WITH Sales_Ranking AS (
				SELECT
					Item_type,
					Outlet_Identifier,
					SUM(Sales) AS Total_Sales,
					Outlet_Establishment_Year,
                    ROW_NUMBER() OVER (PARTITION BY Item_type ORDER BY SUM(Sales) DESC) AS Sales_Rank
				FROM blinkit_grocery_data
				WHERE Outlet_Establishment_Year > 2010
				GROUP BY Item_type, Outlet_Identifier,Outlet_Establishment_Year)
SELECT 
	Item_type,
	Outlet_Identifier,
    Total_Sales,
    Outlet_Establishment_Year
FROM Sales_Ranking
WHERE Sales_Rank = 1
ORDER BY Total_Sales DESC;
-------------------------------------------------------------------------------------------
-- TASK -20. Determine the average sales for items sold at outlets with "Small" size and low visibility (less than 10%).**
-- Insight: Investigate low-visibility products’ performance in smaller outlets.

SELECT
	Outlet_Size,
    AVG(Sales) AS Average_Sales
FROM blinkit_grocery_data
WHERE Outlet_Size = 'small' AND Item_Visibility < 0.10
GROUP BY Outlet_Size;
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
/* **Bonus Questions** */
-------------------------------------------------------------------------------------------
-- TASK -21. What is the revenue contribution of items with ratings between 3.0 and 4.0 in "High" outlet sizes?**
-- Insight: Focus on mid-performing items in larger outlets
WITH Total_High_Outlet_Sizes AS (
						SELECT SUM(SALES) AS High_Outlet_Total_Sales
                        FROM blinkit_grocery_data
                        WHERE Outlet_Size = 'HIGH'),
Mid_Rated_Item_Sales AS (
					SELECT
						Item_Identifier,
						Item_type,
						Rating,
						SUM(Sales) AS Total_Sales
					FROM blinkit_grocery_data
					WHERE Rating BETWEEN 3 AND 4 AND Outlet_Size = 'High'
					GROUP BY Item_Identifier, Item_type, Rating)
SELECT
	mr.Item_Identifier,
    mr.Item_type,
	mr.Rating,
    mr.Total_Sales,
    ROUND(mr.Total_Sales / th.High_Outlet_Total_Sales * 100, 2) AS Revenue_Contribution_Percentage
FROM Mid_Rated_Item_Sales mr, Total_High_Outlet_Sizes th
ORDER BY Revenue_Contribution_Percentage DESC;
---------------------------------------------------------------------------
-- TASK -23. Which outlet and item type combination has the highest deviation from average sales?**
-- Insight: Spot unusual outliers in performance
WITH Total_Average_Sales AS (
							SELECT
								AVG(Sales) AS Average_Sales
							FROM blinkit_grocery_data),	
Total_Outlet_Item_Sales AS (SELECT
								Outlet_Identifier,
								Item_type,
								SUM(Sales) AS Total_Sales
							FROM blinkit_grocery_data
							GROUP BY Outlet_Identifier, Item_type)
SELECT
	tois.Outlet_Identifier,
	tois.Item_type,
    tois.Total_Sales,
    tas.Average_Sales,
    ABS(tois.Total_Sales - tas.Average_Sales) AS Deviation_From_Avg_Sales -- '20750.720904942747'
FROM Total_Outlet_Item_Sales tois
CROSS JOIN Total_Average_Sales tas
ORDER BY Deviation_From_Avg_Sales DESC
LIMIT 1;
-------------------------------------------------------------------------------------
-- TASK -24. For each `Outlet_Type`, identify the top 3 outlets based on total sales of "Snacks".**
-- Insight: Understand performance leaders for popular items.
select DISTINCT(Item_type) from blinkit_grocery_data;
WITH Ranked_Outlets AS (
				SELECT
					ROW_NUMBER() OVER (PARTITION BY Outlet_Type ORDER BY SUM(sales) DESC) AS Row_Num,
					Outlet_Type,
					Outlet_Identifier,
					SUM(Sales) AS Total_Sales
				FROM blinkit_grocery_data
				WHERE Item_type = 'Snack Foods' 
				GROUP BY Outlet_Type, Outlet_Identifier)
SELECT
	Outlet_Type,
	Outlet_Identifier,
	Total_Sales
FROM Ranked_Outlets
WHERE Row_Num <= 3
ORDER BY Outlet_Type, Total_Sales DESC;
-----------------------------------------------------------------
-- TASK-25. Calculate the percentage of items with ratings less than 3.0 contributing to overall sales for each outlet.**
-- Insight: Assess how lower-rated products impact revenue at each location.
WITH Over_All_Sales AS (
						SELECT 
							Outlet_Identifier,
                            SUM(Sales) AS Total_Overall_Sales
                        FROM blinkit_grocery_data
                        GROUP BY Outlet_Identifier),
Sales_less_than_3 AS (
					 SELECT 
						Outlet_Identifier,
                        SUM(Sales) AS Total_Sales_Less_Than_3
                     FROM blinkit_grocery_data
                     WHERE Rating < 3
					 GROUP BY Outlet_Identifier)
SELECT 
	oas.Outlet_Identifier,
    oas.Total_Overall_Sales,
    slt.Total_Sales_Less_Than_3,
    ROUND((slt.Total_Sales_Less_Than_3 / oas.Total_Overall_Sales) * 100, 3) AS percentage_sales_less_than_3
FROM Over_All_Sales oas 
JOIN Sales_less_than_3 slt USING(Outlet_Identifier)
ORDER BY percentage_sales_less_than_3 DESC;
--------------------------------------------------------------------------------------------------------------









