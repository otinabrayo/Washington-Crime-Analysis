SELECT *
FROM CrimeData

-- Which crime type is most common? theft/other

SELECT
DISTINCT(offense),
COUNT(offense) occurence
FROM CrimeData
GROUP BY offense;

-- What time does most crime occur and what type? at evening & theft/other

SELECT
DISTINCT(shift),
COUNT(shift) NoOfTime
FROM CrimeData
GROUP BY shift;

SELECT
DISTINCT(offense),
COUNT(offense) occurences
FROM CrimeData
WHERE shift = 'evening'
GROUP BY offense;

-- Crime rate in Business Improvement Districts(bid) ? most in downtown, less in anacostia

SELECT
DISTINCT(bid),
COUNT(offensekey) offences
FROM CrimeData
WHERE bid != 'Unknown'
GROUP BY bid
ORDER BY offences;

-- Most Crimes in Blocks ? 3100 - 3299 block of 14th street nw &  500 - 799 block of rhode island avenue ne

SELECT
DISTINCT(block),
COUNT(offense) occurences,
CASE
	WHEN COUNT(offense) >= 10 THEN 'High Crime Area'
	WHEN COUNT(offense) >= 5 THEN 'Medium Crime Area'
	ELSE 'Low Crime Area'
END crime_rate_area
FROM CrimeData
GROUP BY block
ORDER BY occurences DESC;


-- Monthly crimes/offences? January

WITH crimerate AS (
	SELECT start_date, offense, offensekey,
	CASE
		WHEN start_date BETWEEN '2024-09-25' AND '2024-12-31' THEN 'Last yr December'
		WHEN start_date BETWEEN '2025-01-01' AND '2025-01-31' THEN 'January'
		WHEN start_date BETWEEN '2025-02-01' AND '2025-02-29' THEN 'February'
		ELSE 'Long time ago'
	END Month
	FROM CrimeData
)
SELECT
DISTINCT(Month),
COUNT(offensekey) 'Offence Numbers'
FROM crimerate
GROUP BY Month
ORDER BY [Offence Numbers] DESC;


-- Crime rate per 100,000 people in each Voting Precinct

WITH CrimeRate AS (
	SELECT
	DISTINCT(voting_precinct),
	COUNT(offensekey) occurences,
	SUM(census_tract) population
	FROM CrimeData
	GROUP BY voting_precinct
)
SELECT voting_precinct,
occurences,
ROUND((occurences * 1.0 /population) * 100000, 2) crime_rate_voting_precinct
FROM CrimeRate
ORDER BY occurences DESC;


-- Crime rate per 100,000 people in the each ward

WITH crime_rate AS(
	SELECT
	DISTINCT(ward),
	COUNT(offensekey) occurence_of_crime,
	SUM(census_tract) population_per_ward
	FROM CrimeData
	GROUP BY ward
)
SELECT ward, occurence_of_crime, population_per_ward,
ROUND((occurence_of_crime * 1.0 / population_per_ward) * 100000, 2) crime_rate_per_ward
FROM crime_rate
ORDER BY crime_rate_per_ward DESC;


-- Crime rate is approximately 11.98 crimes per 100,000 people in Washington

SELECT
SUM(census_tract) population,
COUNT(offensekey) crimes,
ROUND((COUNT(offensekey) * 1.0 / SUM(census_tract) * 100000), 2) crime_rate_in_Washington
FROM CrimeData;


WITH AreaEstimate AS (
    SELECT
        voting_precinct,
        (MAX(latitude) - MIN(latitude)) * (MAX(longitude) - MIN(longitude)) * 69 * 69 area_sq_miles
    FROM CrimeData
    GROUP BY voting_precinct
)
SELECT
    c.voting_precinct,
    CASE
        WHEN a.area_sq_miles > 0 THEN COUNT(c.offensekey) / a.area_sq_miles
        ELSE NULL
    END AS crime_per_sq_mile
FROM CrimeData c
JOIN AreaEstimate a ON c.voting_precinct = a.voting_precinct
GROUP BY c.voting_precinct, a.area_sq_miles
ORDER BY crime_per_sq_mile DESC;


-- Crime severity index

ALTER TABLE CrimeData
ADD crime_index INTEGER;

UPDATE CrimeData
SET crime_index =
    CASE
        WHEN offense = 'homicide' THEN 10
        WHEN offense = 'assault w/dangerous weapon' THEN 9
        WHEN offense = 'sex abuse' THEN 8
        WHEN offense = 'robbery' THEN 7
        WHEN offense = 'motor vehicle theft' THEN 6
        WHEN offense = 'theft f/auto' THEN 5
        WHEN offense = 'theft/other' THEN 4
        WHEN offense = 'burglary' THEN 3
        ELSE NULL
    END;

SELECT * FROM CrimeData;
