/* ============================================================
   US Food Import Analysis (2000-2024): trend and growth views
   ============================================================ */


/* Total U.S. food imports by year (USD billions) */
CREATE VIEW dbo.food_imports_changed_over_time_Billions AS
SELECT YearNum, ROUND(SUM(FoodValue) / 1000, 2) AS Total_Food_Val_Billion
FROM FoodImports
WHERE YearNum >= 2000
GROUP BY YearNum;


/* Import trend per country by year (area chart) */
CREATE VIEW dbo.Countries_Import_Trend_Over_Time AS
SELECT ROUND(SUM(FoodValue), 2) AS ImportValues_Millions, Country, YearNum
FROM FoodImports
WHERE YearNum >= 2000 AND Country != 'REST OF WORLD'
GROUP BY Country, YearNum;


/* Category trends per country by year (stacked area chart) */
CREATE VIEW dbo.Category_Share_Over_Time AS
SELECT Country, YearNum, Category, SUM(FoodValue) AS Food_values
FROM FoodImports
WHERE YearNum >= 2000 AND Country != 'REST OF WORLD'
GROUP BY Category, YearNum, Country;


/* Growth in total food imports, 2019 to 2024 (decimal, e.g. 0.45 = 45%) */
CREATE VIEW dbo.FIVE_YEAR_GROWTH AS
WITH yearly AS (
    SELECT
        SUM(CASE WHEN YearNum = 2019 THEN FoodValue END) AS val_2019,
        SUM(CASE WHEN YearNum = 2024 THEN FoodValue END) AS val_2024
    FROM FoodImports
)
SELECT (val_2024 - val_2019) / val_2019 AS Five_YEAR_GROWTH
FROM yearly;


/* Grand total of food imported since 2000 (USD trillions) */
CREATE VIEW dbo.Total_Food_Imported_Trillion AS
SELECT ROUND(SUM(FoodValue) / 1000000, 2) AS Total_Food_Imported_Trillion
FROM FoodImports
WHERE YearNum >= 2000;

