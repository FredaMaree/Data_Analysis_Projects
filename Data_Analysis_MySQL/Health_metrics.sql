-- DATA CLEANING

SELECT 
    *
FROM
    health_metrics.enhanced_health_data;
use health_metrics;
-- Check for duplicate names
SELECT 
    Name, COUNT(Name)
FROM
    enhanced_health_data
GROUP BY Name
HAVING COUNT(Name) > 1;

-- Review rows for duplicated names
-- 5 Names are duplicated, but the data to each name is unique
SELECT 
    *
FROM
    enhanced_health_data
WHERE
    Name IN ('Jessica Jones' , 'Timothy Williams',
        'Amy Dixon',
        'Steven Webb',
        'Nicole Anderson')
;
-- Assign row numbers to identify duplicates
SELECT Name,
ROW_NUMBER() OVER(PARTITION BY Name ORDER BY Name) as Row_num
FROM enhanced_health_data
;
-- Add a primary key for unique identification
ALTER TABLE enhanced_health_data  ADD COLUMN row_id INT AUTO_INCREMENT PRIMARY KEY;
SELECT 
    *
FROM
    enhanced_health_data;
-- Rename duplicates safely using row number
UPDATE enhanced_health_data t1
JOIN (
    SELECT 
        row_id,
        CONCAT(Name, ' ', ROW_NUMBER() OVER (PARTITION BY Name ORDER BY row_id)) AS new_name
    FROM enhanced_health_data
) t2
ON t1.row_id = t2.row_id
SET t1.Name = t2.new_name;

SELECT 
    *
FROM
    enhanced_health_data;
-- Verify that duplicate names are now unique
SELECT 
    *
FROM
    enhanced_health_data
WHERE
    Name IN ('Jessica Jones 1' , 'Jessica Jones 2',
        'Timothy Williams 1',
        'Timothy Williams 2')
;

-- DATA EXPLORATION
-- Compare gender representation as counts and percentages
SELECT 
    gender,
    COUNT(*) AS count_gender,
    ROUND((COUNT(*) * 100.0 / (SELECT 
                    COUNT(*)
                FROM
                    enhanced_health_data)),
            2) AS percentage
FROM
    enhanced_health_data
GROUP BY gender;

-- Examine minimum and maximum age per gender
SELECT 
    gender, MIN(age) AS min_age, MAX(age) AS max_age
FROM
    enhanced_health_data
GROUP BY gender;
-- Categorize age groups
SELECT 
    age,
    CASE
        WHEN age BETWEEN 18 AND 39 THEN 'young'
        WHEN age BETWEEN 40 AND 65 THEN 'middle_age'
        WHEN age BETWEEN 65 AND 80 THEN 'elderly'
    END AS age_groups
FROM
    enhanced_health_data;
   
 
 -- Count people in each age group
SELECT 
    CASE
        WHEN age BETWEEN 18 AND 39 THEN 'young'
        WHEN age BETWEEN 40 AND 65 THEN 'middle_age'
        WHEN age BETWEEN 66 AND 80 THEN 'elderly'
        ELSE 'other'
    END AS age_group,
    COUNT(*) AS count_people
FROM
    enhanced_health_data
GROUP BY age_group;

 -- Determine percentage distribution of age groups
 SELECT 
    CASE
        WHEN age BETWEEN 18 AND 39 THEN 'young'
        WHEN age BETWEEN 40 AND 65 THEN 'middle_age'
        WHEN age BETWEEN 66 AND 80 THEN 'elderly'
        ELSE 'other'
    END AS age_group,
    COUNT(*) AS count_people,
    ROUND( COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2 ) AS percentage
FROM enhanced_health_data
GROUP BY age_group;


SELECT 
    *
FROM
    enhanced_health_data;


-- Identify individuals with type 1 and type 2 hypertension
SELECT 
    CASE
        WHEN
            `Systolic BP` > 140
                OR `Diastolic BP` > 90
        THEN
            'Type_2_hypertension'
        WHEN
            `Systolic BP` >= 130
                OR `Diastolic BP` >= 80
        THEN
            'Type_1_hypertension'
        ELSE 'No_hypertension'
    END AS Hypertension_classification,
    COUNT(*) AS count_hypertension
FROM
    enhanced_health_data
GROUP BY Hypertension_classification;

-- Determine percentage of individuals with each hypertension type
SELECT 
    CASE
        WHEN
            `Systolic BP` > 140
                OR `Diastolic BP` > 90
        THEN
            'Type_2_hypertension'
        WHEN
            `Systolic BP` >= 130
                OR `Diastolic BP` >= 80
        THEN
            'Type_1_hypertension'
        ELSE 'No_hypertension'
    END AS Hypertension_classification,
    COUNT(*) AS count_hypertension,
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 2)  AS percentage
FROM
    enhanced_health_data
GROUP BY Hypertension_classification;

SELECT 
    *
FROM
    enhanced_health_data;

-- CLassification of cholesterol
-- Review min and max cholesterol values
-- More data required regarding the lipid profile to make conclusions
SELECT 
    MAX(cholesterol), MIN(Cholesterol)
FROM
    enhanced_health_data;

-- Count individuals with high cholesterol
SELECT 
    COUNT(*) AS total_high_cholesterol
FROM
    enhanced_health_data
WHERE
    cholesterol >= 240;

--  Count individuals with borderline high cholesterol
SELECT 
    COUNT(*) AS borderline_high_cholesterol
FROM
    enhanced_health_data
WHERE
    cholesterol BETWEEN 200 AND 239;

-- Review min and max BMI
SELECT 
    ROUND(MAX(BMI), 1), ROUND(MIN(BMI), 1)
FROM
    enhanced_health_data
;
-- Determine obesity prevalence
SELECT 
    COUNT(*) AS obesity
FROM
    enhanced_health_data
WHERE
    BMI >= 30;

-- Obesity counts by gender
SELECT 
    Gender,
    COUNT(*) AS Obesity_Count,
     ROUND(COUNT(*)*100/SUM(COUNT(*)) OVER(),2) as percentage
FROM enhanced_health_data
WHERE BMI >= 30
GROUP BY Gender;

-- Smoker counts
SELECT 
    Smoker, COUNT(*) AS Smoker_count
FROM
    enhanced_health_data
WHERE
    Smoker = 'True'
GROUP BY Smoker;

-- Smoker counts per gender with percentages
SELECT Smoker,Gender,COUNT(*) as Smoker_count,
 ROUND(COUNT(*)*100/SUM(COUNT(*)) OVER(),2) as percentage
FROM enhanced_health_data
WHERE Smoker ='True'
GROUP BY Smoker,Gender;
-- Classify individuals as smoker or non-smoker
SELECT 
    Smoker,
    IF(Smoker = 'True',
        'Smoker',
        'Non_smoker') AS Smoker_status
FROM
    enhanced_health_data;

-- Diabetes counts and percentages
SELECT 
    *
FROM
    enhanced_health_data;
SELECT Diabetes,COUNT(*) as Diabetes_count,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM enhanced_health_data
GROUP BY Diabetes;
-- Classify individuals as diabetic or non-diabetic
SELECT 
    CASE
        WHEN Diabetes = 'True' THEN 'Diabetic'
        ELSE 'Non_diabetic'
    END AS diabetes_status
FROM
    enhanced_health_data;

-- Health classification per gender
SELECT health,gender, COUNT(*) as health_classification,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM enhanced_health_data
Group by Health,gender
Order by Health;

-- Health classification for individuals without comorbidities
-- Criteria: age < 40, normal blood pressure, BMI < 30, non-smoker, non-diabetic
SELECT Health,
       COUNT(*) AS health_without_comorbitities,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM enhanced_health_data
WHERE age < 40 
      AND `Systolic BP` <= 140 
      AND `Diastolic BP` <= 90 
      AND BMI < 30 
      AND Smoker = 'False' 
      AND Diabetes = 'False'
GROUP BY Health
ORDER BY Health;

-- Health classification for individuals with all comorbidities
-- Criteria: age >= 40 and hypertension type 2 and BMI >= 30 and smoker and diabetic
SELECT Health,
       COUNT(*) AS health_with_comorbitities,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM enhanced_health_data
WHERE age >= 40 
      AND `Systolic BP` > 140 
      OR `Diastolic BP` > 90 
      AND BMI >= 30 
      AND Smoker = 'True' 
      AND Diabetes = 'True'
GROUP BY Health
ORDER BY Health;


