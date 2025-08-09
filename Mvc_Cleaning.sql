-- USE Database and View Raw Data
USE Motor_Vehicle_Collisions;
SELECT *
FROM Motor_Vehicle_Collisions;

-- Step 1: Create a new table so we can alter/delete anything if needed
CREATE TABLE mvc
LIKE Motor_Vehicle_Collisions;

INSERT mvc
SELECT *
FROM Motor_Vehicle_Collisions;

SELECT *
FROM mvc;
-- STEP 2: UPDATING column types for DATE and TIME
-- Converting CRASH DATE and CRASH TIME into proper SQL variable types
UPDATE mvc
SET `CRASH DATE` = STR_TO_DATE(`CRASH DATE`, '%m/%d/%Y');

UPDATE mvc
SET `CRASH TIME` = STR_TO_DATE(`CRASH TIME`, '%H:%i');

ALTER TABLE mvc
    MODIFY COLUMN `CRASH DATE` DATE,
    MODIFY COLUMN `CRASH TIME` TIME;
 
-- STEP 3: Check for DUPLICATES
SELECT COLLISION_ID, COUNT(COLLISION_ID) as num_duplicates
FROM mvc
GROUP BY COLLISION_ID
HAVING num_duplicates >1;
-- GOOD news: There are no existing duplicates

-- STEP 4: Check for Missing Values in BOROUGH AND ZIP CODE column
SELECT *
FROM mvc
WHERE BOROUGH = '' AND `ZIP CODE` = '';
-- Because only 156 rows out of 433 have both BOROUGH and ZIP CODE inputs,
-- we won't be able to analyze this data set by geographical analysis

 -- STEP 5: NOW CHECKING IF VALUES NEED TO BE STANDARDIZED
 SELECT *
 FROM mvc;
 
 SELECT `ON STREET NAME`, COUNT(`ON STREET NAME`) as freq_street
 FROM mvc
 GROUP BY `ON STREET NAME`
 ORDER BY `ON STREET NAME`;
 -- Checking if the Distinct function gives a different number of rows returned
 SELECT DISTINCT`ON STREET NAME`
 FROM mvc
 GROUP BY `ON STREET NAME`
 ORDER BY `ON STREET NAME`;
 
 -- Now checking CROSS STREET NAME, OFF STREET NAME
 SELECT `CROSS STREET NAME`, COUNT(`CROSS STREET NAME`) as freq_street
 FROM mvc
 GROUP BY `CROSS STREET NAME`
 ORDER BY `CROSS STREET NAME`;
 
  SELECT DISTINCT`CROSS STREET NAME`
 FROM mvc
 GROUP BY `CROSS STREET NAME`
 ORDER BY `CROSS STREET NAME`;
 
  SELECT `OFF STREET NAME`, COUNT(`OFF STREET NAME`) as freq_street
 FROM mvc
 GROUP BY `OFF STREET NAME`
 ORDER BY `OFF STREET NAME`;
 
 SELECT DISTINCT`OFF STREET NAME`
 FROM mvc
 GROUP BY `OFF STREET NAME`
 ORDER BY `OFF STREET NAME`;
 
 -- checking CFV COLUMN 1
 SELECT `CONTRIBUTING FACTOR VEHICLE 1`, COUNT(`CONTRIBUTING FACTOR VEHICLE 1`) as freq 
 FROM mvc
 GROUP BY `CONTRIBUTING FACTOR VEHICLE 1`
 ORDER BY freq DESC;
 
 SELECT DISTINCT`CONTRIBUTING FACTOR VEHICLE 1`, COUNT(`CONTRIBUTING FACTOR VEHICLE 1`) as freq
 FROM mvc
 GROUP BY `CONTRIBUTING FACTOR VEHICLE 1`
 ORDER BY freq DESC;
 
 -- Standardizing the CONTRIBUTING FACTOR VEHICLE 1 and 2 COLUMN
 -- RECODE "Falling Asleep" inputs to fall into the Driver Inattention column 1
 UPDATE mvc
 SET `CONTRIBUTING FACTOR VEHICLE 1` = "Driver Inattention/Distraction"
 WHERE `CONTRIBUTING FACTOR VEHICLE 1` = 'Fell Asleep' ;
 
 -- Combining multiple related labels into one
UPDATE mvc
 SET `CONTRIBUTING FACTOR VEHICLE 1` = "Passing/Lane Usage/Turning Improper",
	`CONTRIBUTING FACTOR VEHICLE 2` = "Passing/Lane Usage/Turning Improper"
 WHERE `CONTRIBUTING FACTOR VEHICLE 1` IN ('Unsafe Lane Changing', 'Turning Improperly')
 OR `CONTRIBUTING FACTOR VEHICLE 2` IN ('Unsafe Lane Changing', 'Turning Improperly');
 
 UPDATE mvc
 SET `CONTRIBUTING FACTOR VEHICLE 1` = 'Passing/Lane Usage/Turning Improper',
 `CONTRIBUTING FACTOR VEHICLE 2` = 'Passing/Lane Usage/Turning Improper'
 WHERE `CONTRIBUTING FACTOR VEHICLE 1`= 'Passing or Lane Usage Improper'
 OR `CONTRIBUTING FACTOR VEHICLE 2`= 'Passing or Lane Usage Improper';
 
 -- Combining 'Failure to Yield Right of Way' under 'Traffic Control Disregarded'
 UPDATE mvc
 SET `CONTRIBUTING FACTOR VEHICLE 1` = 'Traffic Control Disregarded',
 `CONTRIBUTING FACTOR VEHICLE 2` = 'Traffic Control Disregarded'
 WHERE `CONTRIBUTING FACTOR VEHICLE 1` = 'Failure to Yield Right-of-Way'
 OR `CONTRIBUTING FACTOR VEHICLE 2` = 'Failure to Yield Right-of-Way';
 
 -- Now standardizing the null values into 'Unspecified' in column 1 since a null value is meaningless in the CFV 1 column
 UPDATE mvc 
 SET `CONTRIBUTING FACTOR VEHICLE 1` = 'Unspecified'
 WHERE `CONTRIBUTING FACTOR VEHICLE 1` = '';
 
 -- Fix Typo
 UPDATE mvc
 SET `CONTRIBUTING FACTOR VEHICLE 1` = 'Illness'
 WHERE `CONTRIBUTING FACTOR VEHICLE 1` = 'Illnes';

 -- STEP 7: Repeat Standardization for VEHICLE 2
  SELECT `CONTRIBUTING FACTOR VEHICLE 2`, COUNT(`CONTRIBUTING FACTOR VEHICLE 2`) as freq 
 FROM mvc
 GROUP BY `CONTRIBUTING FACTOR VEHICLE 2`
 ORDER BY freq DESC;
 
 SELECT DISTINCT`CONTRIBUTING FACTOR VEHICLE 2`, COUNT(`CONTRIBUTING FACTOR VEHICLE 2`) as freq
 FROM mvc
 GROUP BY `CONTRIBUTING FACTOR VEHICLE 2`
 ORDER BY freq DESC;
 
 -- STEP 8: Checking if Vehicle type code columns needs to be standardized

SELECT `VEHICLE TYPE CODE 1`, COUNT(`VEHICLE TYPE CODE 1`) as freq
 FROM mvc
 GROUP BY `VEHICLE TYPE CODE 1`
 ORDER BY freq DESC;
 
SELECT `VEHICLE TYPE CODE 2`, COUNT(`VEHICLE TYPE CODE 2`) as freq
 FROM mvc
 GROUP BY `VEHICLE TYPE CODE 2`
 ORDER BY freq DESC;
 
 SELECT `VEHICLE TYPE CODE 3`, COUNT(`VEHICLE TYPE CODE 3`) as freq
 FROM mvc
 GROUP BY `VEHICLE TYPE CODE 3`
 ORDER BY freq DESC;
 
  SELECT `VEHICLE TYPE CODE 4`, COUNT(`VEHICLE TYPE CODE 4`) as freq
 FROM mvc
 GROUP BY `VEHICLE TYPE CODE 4`
 ORDER BY freq DESC;
 
  SELECT `VEHICLE TYPE CODE 5`, COUNT(`VEHICLE TYPE CODE 5`) as freq
 FROM mvc
 GROUP BY `VEHICLE TYPE CODE 5`
 ORDER BY freq DESC;
 
 -- The value '4 dr sedan' can be standardized into the value 'Sedan' in VTC 3 column
UPDATE mvc
 SET `VEHICLE TYPE CODE 2` = 'Sedan'
 WHERE `VEHICLE TYPE CODE 2` = '4 dr sedan';
 
 -- STEP 9: VIEWING THE FINAL CLEAN DATA
SELECT *
FROM mvc;
 