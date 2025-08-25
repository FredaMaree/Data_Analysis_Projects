# DATA CLEANING
use us_project;
SELECT * 
FROM us_project.us_household_income;

SELECT * 
FROM us_project.us_household_income_statistics;
ALTER TABLE us_project.us_household_income_statistics RENAME COLUMN `ï»¿id`TO `id`
;

SELECT COUNT(id) 
FROM us_project.us_household_income;

SELECT COUNT(id)
FROM us_project.us_household_income_statistics;

-- 1 Look for duplicate id's
SELECT id,COUNT(id) 
FROM us_project.us_household_income
GROUP BY id
HAVING COUNT(id)>1
;

SELECT *
FROM (
SELECT row_id,id,
ROW_NUMBER () OVER (PARTITION BY id ORDER BY id)row_num
FROM  us_project.us_household_income) as duplicates
WHERE row_num>1; 
-- 2 Delete duplicateid's 
DELETE FROM us_project.us_household_income
WHERE row_id IN (
SELECT row_id
FROM (
SELECT row_id,id,
ROW_NUMBER () OVER (PARTITION BY id ORDER BY id) AS row_num
FROM  us_project.us_household_income) as duplicates
WHERE row_num>1
);

ALTER TABLE ushouseholdincome_statistics RENAME TO us_household_income_statistics;
-- 3 Look for duplicate id's in us_household_income_statistics: none found
SELECT id, COUNT(id)
FROM us_household_income_statistics
GROUP BY id
Having COUNT(id) >1
;
SELECT * 
FROM us_project.us_household_income;
-- 4 Check spelling of state names
SELECT * 
FROM us_project.us_household_income_statistics;
-- Delete and re-insert where statistics are zero
DELETE 
from us_project.us_household_income_statistics
WHERE Mean = 0 
   OR Median = 0
   OR Stdev = 0
   OR sum_w = 0;
   
   INSERT INTO us_project.us_household_income_statistics
SELECT *
FROM us_project.us_household_income_statistics_backup
WHERE Mean = 0 
   OR Median = 0
   OR Stdev = 0
   OR sum_w = 0;
   SELECT * 
FROM us_project.us_household_income_statistics
WHERE Mean = 0 
   OR Median = 0
   OR Stdev = 0
   OR sum_w = 0;

-- 5 Update spelling of state names
UPDATE us_project.us_household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia'
;
UPDATE us_project.us_household_income
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama'
;
-- 6 Populate missing data in the place colum
SELECT *
FROM  us_project.us_household_income
WHERE place = '';

SELECT *
FROM  us_project.us_household_income
WHERE county ='Autauga County' ;

UPDATE us_project.us_household_income
SET place = 'Autaugaville'
WHERE COUNTY = 'Autauga County'
AND city ='Vinemont'
;
SELECT *
FROM  us_project.us_household_income
;
SELECT type,COUNT(type)
from  us_project.us_household_income
GROUP BY type
;
-- 7 Correct spelling in type column
UPDATE us_project.us_household_income
SET type= 'Borough'
WHERE type = 'Boroughs'
;

-- 8 Look for missing  in Awater and Aland columns

SELECT DISTINCT Awater,Aland
from  us_project.us_household_income
WHERE Awater =0 OR Awater =''OR Awater is NULL
AND Aland =0 OR Aland =''OR Aland is NULL
;

-- DATA EXPLORATION
--  Landarea per state
SELECT DISTINCT State_Name, SUM(ALand) as total_Aland
FROM us_project.us_household_income
GROUP bY State_Name
ORDER BY total_Aland Desc
;
--  Waterarea per state
 SELECT DISTINCT State_Name, SUM(Awater) as total_Awater 
FROM us_project.us_household_income
GROUP bY State_Name
ORDER BY total_Awater Desc
;
--  Comparison of water and land area per state
SELECT DISTINCT State_Name, SUM(Awater) as total_Awater,  SUM(Aland) as total_Aland 
FROM us_project.us_household_income
GROUP bY State_Name
ORDER BY 3 Desc
;
--  Top 10 states according to land area
SELECT DISTINCT State_Name,  SUM(Awater) as total_Awater,  SUM(Aland) as total_Aland 
FROM us_project.us_household_income
GROUP bY State_Name
ORDER BY 3 Desc
Limit 10
;
--  Top 10 states according to water area
SELECT DISTINCT State_Name,  SUM(Awater) as total_Awater,  SUM(Aland) as total_Aland 
FROM us_project.us_household_income
GROUP bY State_Name
ORDER BY 2 Desc
Limit 10
;
-- Combing tables with inner join
-- Mean of 0 indicates inaccurate reporting
SELECT *
FROM  us_project.us_household_income i
INNER JOIN us_project.us_household_income_statistics s
	ON i.id=s.id
    WHERE mean <>0
    ;
--  AVERAGE median and mean income per state
    SELECT i.State_name, ROUND(AVG( Mean),1), ROUND(AVG(Median),1)
FROM  us_project.us_household_income i
INNER JOIN us_project.us_household_income_statistics s
	ON i.id=s.id
    WHERE mean <>0
    GROUP BY i.State_name
    ORDER BY 2 DESC
    LIMIT 10
   ;
    
SELECT *
FROM  us_project.us_household_income_statistics
;
--  Look at income vs different areas in the type column
-- FIlter out the outliers by using having function
   SELECT type, COUNT(Type), ROUND(AVG( Mean),1), ROUND(AVG(Median),1)
FROM  us_project.us_household_income i
INNER JOIN us_project.us_household_income_statistics s
	ON i.id=s.id
    WHERE mean <>0
    GROUP BY type 
    having COUNT(type) >100
    ORDER BY 2 DESC
    LIMIT 20
   ;
   --  Evaluate income in different cities, and identify high household income cities
   SELECT i.State_name, city, ROUND(AVG( Mean),1), ROUND(AVG(Median),1)
FROM  us_project.us_household_income i
INNER JOIN us_project.us_household_income_statistics s
	ON i.id=s.id
    WHERE mean <>0
    GROUP BY State_name, city
    ORDER BY 3 DESC
    ;
    
    