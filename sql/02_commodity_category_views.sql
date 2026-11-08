/* ============================================================
   US Food Import Analysis (2000-2024): commodity and category views
   ============================================================ */


/* Import value by commodity for each country (table visual) */
CREATE VIEW dbo.Countries_Commodity_Breakdown AS
SELECT Country, Commodity, SUM(FoodValue) AS Food_Val
FROM FoodImports
WHERE YearNum >= 2000 AND Country != 'REST OF WORLD'
GROUP BY Country, Commodity;


/* Top 3 commodities per country, everything else grouped (donut chart) */
CREATE VIEW dbo.Countries_Commodity_Group AS
WITH CTE AS (
    SELECT
        Country,
        Commodity,
        SUM(FoodValue) AS Food_values,
        DENSE_RANK() OVER (PARTITION BY Country ORDER BY SUM(FoodValue) DESC) AS rnk
    FROM FoodImports
    WHERE YearNum >= 2000 AND Country != 'REST OF WORLD'
    GROUP BY Country, Commodity
)
SELECT
    Country,
    CASE WHEN rnk <= 3 THEN Commodity ELSE 'All Other Commodities' END AS Commodity_Group,
    SUM(Food_values) AS Total_FoodValue
FROM CTE
GROUP BY Country,
         CASE WHEN rnk <= 3 THEN Commodity ELSE 'All Other Commodities' END;


/* Which country is the #1 supplier of each commodity? (excludes subtotal rows) */
CREATE VIEW dbo.Countries_Dominate_Commodities AS
WITH CTE AS (
    SELECT
        Country,
        Commodity,
        ROUND(SUM(FoodValue), 2) AS Total_Food_Val,
        DENSE_RANK() OVER (PARTITION BY Commodity ORDER BY ROUND(SUM(FoodValue), 2) DESC) AS ranks
    FROM FoodImports
    WHERE Commodity NOT LIKE '%Total%'
    GROUP BY Country, Commodity
)
SELECT Country, Commodity, Total_Food_Val
FROM CTE
WHERE ranks = 1;


/* Import value by category per country (pie chart) */
CREATE VIEW dbo.Category_Mix AS
SELECT Country, Category, SUM(FoodValue) AS Foodval
FROM FoodImports
WHERE YearNum >= 2000 AND Country != 'REST OF WORLD'
GROUP BY Country, Category;


/* Top 10 food categories overall (USD billions) */
CREATE VIEW dbo.top_10_Food_Categories AS
SELECT TOP 10 Category, ROUND(SUM(FoodValue) / 1000, 2) AS Total_Val_Billion
FROM FoodImports
WHERE YearNum >= 2000
GROUP BY Category
ORDER BY SUM(FoodValue) DESC;

