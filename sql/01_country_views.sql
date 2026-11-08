/* 
   US Food Import Analysis (2000-2024): country views
   SQL Server (SSMS) | Database: US_Food_Import | Table: dbo.FoodImports
   FoodValue is in USD millions.
   'REST OF WORLD' is excluded where the view compares individual countries.
    */


/* Country slicer list */
CREATE VIEW COUNTRIS_LIST AS
SELECT Country
FROM FoodImports
WHERE YearNum >= 2000 AND Country != 'REST OF WORLD'
GROUP BY Country;


/* How many countries does the U.S. import food from? */
CREATE VIEW Number_of_Active_Imported_Countries AS
SELECT Country
FROM FoodImports
WHERE YearNum >= 2000 AND Country != 'REST OF WORLD'
GROUP BY Country;


/* KPI: import rank for each country */
CREATE VIEW COUNTRY_RANKS AS
SELECT
    Country,
    SUM(FoodValue) AS TOTAL_IMPORT_VAL,
    RANK() OVER (ORDER BY SUM(FoodValue) DESC) AS rnks
FROM FoodImports
WHERE YearNum >= 2000 AND Country != 'REST OF WORLD'
GROUP BY Country;


/* KPI: number of commodity records imported per country */
CREATE VIEW Countries_Commodities_Imported AS
SELECT COUNT(Commodity) AS Commodities_Imported, Country
FROM FoodImports
WHERE YearNum >= 2000 AND Country != 'REST OF WORLD'
GROUP BY Country;


/* KPI: each country's share of total U.S. food imports */
CREATE VIEW COUNTRIES_Percentage_of_Total_US_Food_Imports AS
WITH country_totals AS (
    SELECT Country, SUM(FoodValue) AS Countries_Total_Imports
    FROM FoodImports
    WHERE YearNum >= 2000 AND Country != 'REST OF WORLD'
    GROUP BY Country
),
us_total AS (
    SELECT SUM(FoodValue) AS Total_Imports
    FROM FoodImports
    WHERE YearNum >= 2000
)
SELECT
    c1.Country AS Countries,
    c1.Countries_Total_Imports AS Countries_Imports,
    c1.Countries_Total_Imports * 1.0 / c2.Total_Imports AS Countries_Import_Percentage
FROM country_totals c1
CROSS JOIN us_total c2;


/* KPI: total import value per country (USD billions) */
CREATE VIEW Countries_Total_Import_Value_Billions AS
SELECT Country, ROUND(SUM(FoodValue) / 1000, 2) AS Countries_Total_Import_Value_Billions
FROM FoodImports
WHERE YearNum >= 2000 AND Country != 'REST OF WORLD'
GROUP BY Country;


/* Top 10 supplier countries (USD billions) */
CREATE VIEW TOP_10_COUNTRIES_IMPORTS AS
WITH CTE AS (
    SELECT
        Country,
        ROUND(SUM(FoodValue) / 1000, 2) AS Food_Imported,
        RANK() OVER (ORDER BY SUM(FoodValue) DESC) AS ranks
    FROM FoodImports
    WHERE YearNum >= 2000 AND Country != 'REST OF WORLD'
    GROUP BY Country
)
SELECT Country, Food_Imported
FROM CTE
WHERE ranks <= 10;


/* Top single country. Rank 1 is 'REST OF WORLD', so the top named country is rank 2. */
CREATE VIEW Top_Country_Imported AS
WITH CTE AS (
    SELECT SUM(FoodValue) AS total_food_val, Country,
           RANK() OVER (ORDER BY SUM(FoodValue) DESC) AS rnk
    FROM FoodImports
    WHERE YearNum >= 2000
    GROUP BY Country
)
SELECT Country, total_food_val
FROM CTE
WHERE rnk = 2;


/* 'REST OF WORLD' vs. countries outside the top 10 */
ALTER VIEW Rest_Of_The_World_Imports AS
WITH CTE AS (
    SELECT
        Country,
        ROUND(SUM(FoodValue) / 1000, 2) AS Food_Imported,
        RANK() OVER (ORDER BY SUM(FoodValue) DESC) AS ranks
    FROM FoodImports
    WHERE YearNum >= 2000
    GROUP BY Country
)
SELECT Country, Food_Imported
FROM CTE
WHERE ranks = 1 OR ranks NOT BETWEEN 2 AND 11;

