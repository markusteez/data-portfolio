-- ANALYSIS: NYC Motor Vehicle Collision Data
-- Objective: Explore crash trends, contributing factors, and location-based patterns

USE mvc;
-- INITIAL TABLE VIEW
SELECT * FROM mvc;

-- ---------------------------------------------------
-- 1. CRASH TREND ANALYSIS – BY MONTH
-- ---------------------------------------------------

-- Date range check
SELECT MIN(`CRASH DATE`), MAX(`CRASH DATE`)
FROM mvc;
-- 15 month analysis from April 2021-July 2022

-- Monthly frequency of crashes + average crashes per month
WITH months AS (
SELECT 1 AS month UNION ALL
SELECT 2 UNION ALL
SELECT 3 UNION ALL
SELECT 4 UNION ALL
SELECT 5 UNION ALL
SELECT 6 UNION ALL
SELECT 7 UNION ALL
SELECT 8 UNION ALL
SELECT 9 UNION ALL
SELECT 10 UNION ALL
SELECT 11 UNION ALL
SELECT 12
),
freq_table AS
(
SELECT MONTH(`CRASH DATE`) as crash_month, COUNT(`CRASH DATE`) AS num_crashes
FROM mvc
GROUP BY crash_month
)
SELECT m.month AS crash_month, COALESCE(f.num_crashes, 0) as num_crashes, AVG(COALESCE(f.num_crashes, 0)) OVER () as average_crashes_per_month
FROM months m
LEFT JOIN freq_table f
ON m.month = f.crash_month
ORDER BY num_crashes DESC;

-- Observation: September, March, December, and July exceed monthly average.

-- ---------------------------------------------------
-- 2. CRASH TREND ANALYSIS – BY HOUR
-- ---------------------------------------------------
WITH freq_table AS
(
SELECT HOUR(`CRASH TIME`) as crash_hour, COUNT(COLLISION_ID) AS num_crashes
FROM mvc
GROUP BY crash_hour
)
SELECT crash_hour,num_crashes, AVG(num_crashes) OVER() AS avg_crashes_per_hour, ABS(num_crashes-AVG(num_crashes) OVER()) AS deviation_from_mean
FROM freq_table
ORDER BY num_crashes DESC;

-- Observation: 9 PM is a peak hour with 44 crashes—significantly above the average.

-- ---------------------------------------------------
-- 3. CONTRIBUTING FACTORS OVERVIEW
-- ---------------------------------------------------

SELECT `CONTRIBUTING FACTOR VEHICLE 1`, COUNT(COLLISION_ID) AS num_crashes
FROM mvc
GROUP BY `CONTRIBUTING FACTOR VEHICLE 1`
ORDER BY num_crashes DESC;

-- Top factor: Driver Inattention/Distraction

-- ---------------------------------------------------
-- 4. MOST ACCIDENT-PRONE VEHICLE TYPES
-- ---------------------------------------------------

SELECT `VEHICLE TYPE CODE 1`, COUNT(COLLISION_ID) AS num_crashes
FROM mvc
GROUP BY `VEHICLE TYPE CODE 1`
ORDER BY num_crashes DESC;

-- Top 3 vehicle types: Sedan, SUV, Taxi

-- ---------------------------------------------------
-- 5. TOP FACTORS BY VEHICLE TYPE (TOP 2 PER TYPE)
-- ---------------------------------------------------

WITH factor_counts as
(
SELECT `VEHICLE TYPE CODE 1` as vehicle_type, `CONTRIBUTING FACTOR VEHICLE 1` as factor, COUNT(COLLISION_ID) AS num_crashes
FROM mvc
WHERE `VEHICLE TYPE CODE 1` <>'' AND `CONTRIBUTING FACTOR VEHICLE 1` <>'Unspecified'
GROUP BY vehicle_type, factor
ORDER BY num_crashes DESC
),
ranking as
(
SELECT vehicle_type, factor, num_crashes,
RANK() OVER(PARTITION BY vehicle_type ORDER BY num_crashes DESC) as ranking
FROM factor_counts
)
SELECT vehicle_type, factor,num_crashes, ranking
FROM ranking
WHERE ranking = 1 OR ranking = 2
ORDER BY num_crashes DESC
;
-- Summary:
-- - Sedan & SUV: Driver Inattention and Passing/Lane Usage/Turning Improper
-- - Taxi: Driver Inattention and Following Too Closely

-- ---------------------------------------------------
-- 6. FACTORS ASSOCIATED WITH INJURIES & FATALITIES
-- ---------------------------------------------------

-- View individual fatal crashes
SELECT *
FROM mvc
WHERE `NUMBER OF PERSONS KILLED` = 1;
-- In collision id 4456659 by a Bus and 4487210 by a taxi one person was killed in their accident
-- Factor is unkown by each

-- Aggregate injuries and fatalities by factor
WITH t1 as
(
SELECT `CONTRIBUTING FACTOR VEHICLE 1` as factor,`NUMBER OF PERSONS INJURED` as num_inj, `NUMBER OF PERSONS KILLED` as num_killed
FROM mvc
WHERE `NUMBER OF PERSONS INJURED` <>0 OR `NUMBER OF PERSONS KILLED` <>0
)
SELECT factor, SUM(num_inj) OVER(PARTITION BY factor) as total_inj_by_factor, SUM(num_killed) OVER(PARTITION BY factor) as total_killed_by_factor
FROM t1
ORDER BY total_inj_by_factor DESC;

-- Top injury factors: Driver Inattention(40), Unspecified(37), Traffic Control Disregarded(34)

-- ---------------------------------------------------
-- 7. TIME-BASED FACTOR CORRELATION
-- ---------------------------------------------------

WITH t1 as
(
SELECT HOUR(`CRASH TIME`) as crash_hour, `CONTRIBUTING FACTOR VEHICLE 1` AS factor,COLLISION_ID
FROM mvc
)
SELECT crash_hour, factor,COUNT(COLLISION_ID) AS num_crashes, AVG(COUNT(COLLISION_ID)) OVER(PARTITION BY factor) as avg_crash_by_factor
FROM t1
GROUP BY 1,2
ORDER BY crash_hour,num_crashes DESC;
-- Notable findings:
-- - 2 AM: Alcohol Involvement
-- - 5 PM & 3 PM: Driver Inattention
-- - 8 AM, 10 AM, 6–7 PM: Factor-specific spikes

-- ---------------------------------------------------
-- 8. GEOGRAPHICAL ANALYSIS: FACTORS BY BOROUGH
-- ---------------------------------------------------

WITH t1 as
(
SELECT `BOROUGH`, `CONTRIBUTING FACTOR VEHICLE 1` AS factor,COLLISION_ID
FROM mvc
WHERE `BOROUGH`<>''
)
SELECT `BOROUGH`, factor,COUNT(COLLISION_ID) AS num_crashes, AVG(COUNT(COLLISION_ID)) OVER(PARTITION BY factor) as avg_crash_by_factor
FROM t1
GROUP BY 1,2
ORDER BY `BOROUGH`,num_crashes DESC;

-- Summary:
-- - Brooklyn: Highest crashes from Driver Inattention
-- - Queens: Higher in Passing/Lane Usage and Traffic Disregard

-- ---------------------------------------------------
-- 9. BOROUGH-LEVEL INJURY & ACCIDENT RATES
-- ---------------------------------------------------

-- Total injuries by borough

SELECT  `NUMBER OF PERSONS INJURED`, `BOROUGH`,SUM(`NUMBER OF PERSONS INJURED`) OVER(PARTITION BY `BOROUGH`) as total_inj
FROM mvc
WHERE `BOROUGH`<>'';

-- Total accidents by borough
SELECT  `BOROUGH`,COUNT(COLLISION_ID) OVER(PARTITION BY `BOROUGH`) as total_accidents
FROM mvc
WHERE `BOROUGH`<>'';

-- Injury to accident ratio
WITH injured as
(
SELECT  `NUMBER OF PERSONS INJURED`, `BOROUGH`,SUM(`NUMBER OF PERSONS INJURED`) OVER(PARTITION BY `BOROUGH`) as total_inj
FROM mvc
WHERE `BOROUGH`<>''
), accidents as
(
SELECT  `BOROUGH`,COUNT(COLLISION_ID) OVER(PARTITION BY `BOROUGH`) as total_accidents
FROM mvc
WHERE `BOROUGH`<>''
)
SELECT i.`BOROUGH`,total_accidents, total_inj, total_accidents/total_inj as percentage
FROM injured i
LEFT JOIN accidents a
ON i.`BOROUGH`=a.`BOROUGH`;

-- Brooklyn: Highest number of both injuries and accidents
-- Staten Island: Least impact
-- Injury rates are relatively consistent across boroughs

