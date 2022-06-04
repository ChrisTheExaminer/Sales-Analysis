/* Data cleaning & Data Exploration

Sales of products for 12 months period.

Sales Analysis
About the Dataset
The dataset consists of 11 columns, each column representing an attribute of purchase on a product -
Order ID - A unique ID for each order placed on a product
Product - Item that is purchased
Quantity Ordered - Describes how many of that products are ordered
Price Each - Price of a unit of that product
Order Date - Date on which the order is placed
Purchase Address - Address to where the order is shipped
Month, Sales, City, Hour - Extra attributes formed from the above.
*/

--------------------------------------------------------------Data-Cleaning--------------------------------------------------------------------------- 
--View the entire table.

SELECT * FROM Sales_Data;

--Change date format.

UPDATE Sales_Data
SET [Order Date] = cast([Order Date] as DATE);

-- Another way to change the date format.

ALTER TABLE Sales_Data
ADD [Order Date converted] date;

UPDATE Sales_Data
SET [Order Date converted] = cast([Order Date] as DATE);

--As we have two Order Date columns, we will drop the initial column and keep the converted format.

ALTER TABLE Sales_Data
DROP COLUMN [Order Date];

--Let's seperate street address, city and zip code from the Purchase Address column.

SELECT [Purchase Address], PARSENAME(REPLACE([Purchase Address], ',','.'), 3) AS [Street Address], 
PARSENAME(REPLACE([Purchase Address], ',','.'), 2) AS [City],
PARSENAME(REPLACE([Purchase Address], ',','.'), 1) AS [Zip Code]
FROM Sales_Data;

--Let's update the table now.

ALTER TABLE Sales_Data
ADD [Street Address] NVARCHAR(50)

UPDATE Sales_Data
SET [Street Address] = PARSENAME(REPLACE([Purchase Address], ',','.'), 3);

ALTER TABLE Sales_Data
ADD [Zip Code] NVARCHAR(50);

UPDATE Sales_Data
SET [Zip Code] = PARSENAME(REPLACE([Purchase Address], ',','.'), 1);

--Column Sales includes the price of a unit of that product which we already have in column Price Each.
--Drop column Sales

ALTER TABLE Sales_Data
DROP COLUMN Sales;

--Drop Unnecessary column

ALTER TABLE Sales_Data
DROP COLUMN Hour;

-- Remove Duplicate.

WITH DUPLICATE AS (
SELECT *, ROW_NUMBER () OVER (PARTITION BY [Order ID], [Purchase Address] ORDER BY [F1]) row_num FROM Sales_Data)
SELECT * FROM DUPLICATE
--DELETE FROM DUPLICATE
WHERE row_num > 1;

--------------------------------------------------------------Data-Exploration---------------------------------------------------------------------

----Different Products sold a year at the price of a unit of that product.

SELECT DISTINCT([Product]), [Price Each]
FROM Sales_Data
ORDER BY 2;

--Cities that stand out. We can see that the products were sold in 9 different cities.

SELECT DISTINCT([City]) FROM Sales_Data;

--Total number of products sold by category.

SELECT DISTINCT([Product]), [Price Each], SUM([Quantity Ordered]) AS [Quantity Sold]
FROM Sales_Data
GROUP BY Product, [Price Each]
ORDER BY 1;

-- Total quantity of products sold.

SELECT SUM([Quantity Ordered]) AS [Total Quantity] FROM Sales_Data;

--Sales Revenue.

SELECT DISTINCT([Product]), [Price Each], SUM([Quantity Ordered]) AS [Quantity Sold],
ROUND(([Price Each]*SUM([Quantity Ordered])), 0) AS [Sales Revenue]
FROM Sales_Data
GROUP BY Product, [Price Each]
ORDER BY 1;

--Total Revenue.

CREATE VIEW Total_Revenue AS
With Temp AS
(SELECT DISTINCT([Product]), [Price Each], SUM([Quantity Ordered]) AS [Quantity Sold],
ROUND(([Price Each]*SUM([Quantity Ordered])), 0) AS [Sales Revenue]
FROM Sales_Data
GROUP BY Product, [Price Each])
SELECT [Product], [Price Each], [Quantity Sold], [Sales Revenue], 
(SELECT SUM([Sales Revenue]) FROM Temp) AS [Total Revenue]
FROM Temp
GROUP BY [Product], [Price Each], [Quantity Sold], [Sales Revenue];

--Average Revenue per unit.

WITH Temp2 AS 
(SELECT Product, [Price Each], [Quantity Sold], [Sales Revenue], [Total Revenue],
(SELECT SUM([Quantity Sold]) FROM Total_Revenue) AS [Total Quantity]
FROM Total_Revenue)
SELECT  Product, [Price Each], [Quantity Sold], [Sales Revenue], [Total Revenue], 
[Total Quantity],
ROUND(([Total Revenue]/[Total Quantity]), 2) AS ARPU
FROM Temp2;

--Quantity of items ordered by each city.

SELECT DISTINCT(Product), City, SUM([Quantity Ordered]) AS [Quantity Ordered By City]
FROM Sales_Data
GROUP BY Product, City
ORDER BY 1;

--Number of items sold per month by category.

SELECT DISTINCT(Product), SUM([Quantity Ordered]) AS [Quantity Ordered By City], Month
FROM Sales_Data
GROUP BY Product, Month
ORDER BY 3;

--Monthly revenue.

SELECT DISTINCT(Product), [Price Each],SUM([Quantity Ordered]) AS [Quantity Ordered By City], Month,
ROUND(([Price Each]*SUM([Quantity Ordered])), 0) AS [Monthly Revenue]
FROM Sales_Data
GROUP BY Product, Month, [Price Each]
ORDER BY 4;


------------------------------------------------------------------End-Of-Project--------------------------------------------------------------------