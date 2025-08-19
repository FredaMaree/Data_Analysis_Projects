
  -- ==========================================
-- DATA PREPARATION & CLEANING
-- ==========================================

-- 1. Check for duplicate records  
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;

-- 2. Review duplicates using row numbers  
SELECT Row_ID, CONCAT(Country, Year), 
ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS row_num
FROM world_life_expectancy;

-- 3. Delete duplicate entries  
DELETE FROM world_life_expectancy
WHERE Row_ID IN(
    SELECT Row_ID
    FROM (
        SELECT Row_ID, CONCAT(Country, Year),
        ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS row_num
        FROM world_life_expectancy
    ) AS row_table
    WHERE row_num > 1
);

-- 4. Identify missing status values  
SELECT *
FROM world_life_expectancy
WHERE Status = '';

-- 5. Impute missing status using country-level data  
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = '' AND t2.Status <> '' AND t2.Status = 'Developing';

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = '' AND t2.Status <> '' AND t2.Status = 'Developed';

-- 6. Re-check for missing/NULL status  
SELECT *
FROM world_life_expectancy
WHERE Status = '';

-- 7. Identify missing life expectancy values  
SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` = '';

-- 8. Estimate missing values from adjacent years  
SELECT t1.Country, t1.Year, t1.`Life expectancy`, 
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2, 1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2 ON t1.Country = t2.Country AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3 ON t1.Country = t3.Country AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = '';

-- 9. Update life expectancy with calculated averages  
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2 ON t1.Country = t2.Country AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3 ON t1.Country = t3.Country AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2, 1)
WHERE t1.`Life expectancy` = '';

-- 10. Final review of cleaned dataset  
SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` = '';

-- ==========================================
-- EXPLORATORY DATA ANALYSIS (EDA)
-- ==========================================

-- 1. Life Expectancy Trends  
--    - Min, max, and 15-year change  
SELECT Country, MIN(`Life expectancy`), MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1) AS life_increase_15_years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
ORDER BY life_increase_15_years DESC;

--    - Average life expectancy by year  
SELECT Year, ROUND(AVG(`Life expectancy`), 2)
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year;

-- 2. GDP Analysis  
--    - Avg life expectancy vs GDP (per country)  
SELECT Country, ROUND(AVG(`Life expectancy`), 1), ROUND(AVG(GDP), 1)
FROM world_life_expectancy
GROUP BY Country
HAVING ROUND(AVG(`Life expectancy`), 1) > 0
AND ROUND(AVG(GDP), 1) > 0
ORDER BY ROUND(AVG(GDP), 1) DESC;

--    - High GDP vs Low GDP group comparison  
SELECT 
CASE WHEN GDP >= 1500 THEN 'High GDP' ELSE 'Low GDP' END AS gdp_group,
ROUND(AVG(`Life expectancy`), 1)
FROM world_life_expectancy
WHERE GDP > 0
GROUP BY gdp_group;

-- 3. Development Status Analysis  
--    - Avg life expectancy by development status  
SELECT Status, ROUND(AVG(`Life expectancy`), 1)
FROM world_life_expectancy
GROUP BY Status;

--    - Country counts per status group  
SELECT Status, COUNT(DISTINCT Country)
FROM world_life_expectancy
GROUP BY Status;

--    - Status vs combined averages and countries  
SELECT Status, ROUND(AVG(`Life expectancy`), 1), COUNT(DISTINCT Country)
FROM world_life_expectancy
GROUP BY Status;

-- 4. BMI Analysis  
--    - Relationship between BMI and life expectancy  
SELECT Country, ROUND(AVG(`Life expectancy`), 1), ROUND(AVG(BMI), 1)
FROM world_life_expectancy
GROUP BY Country
HAVING ROUND(AVG(`Life expectancy`), 1) > 0
AND ROUND(AVG(BMI), 1) > 0
ORDER BY ROUND(AVG(BMI), 1) DESC;

-- 5. Mortality Trends  
--    - Cumulative adult mortality by country and year  
SELECT Country, Year, `Life expectancy`, `Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS rolling_total
FROM world_life_expectancy;

  
  