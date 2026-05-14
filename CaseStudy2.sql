SELECT *
FROM T20I

# Q1: Identify matches between 2 specific teams (e.g., India and South Africa) in 2024 and their result
SELECT *
FROM T20I
WHERE (Team1 = 'South Africa' AND Team2 = 'India') OR (Team2 = 'South Africa' AND Team1 = 'India')
AND YEAR(Matchdate) = 2024

# Q2: Find the team with the highest number of wins in 2024 and the total matches it won
SELECT Winner, COUNT(*)AS `Number of Wins`
FROM T20I
GROUP BY Winner
ORDER BY `Number of Wins` DESC
LIMIT 1
# Answer: India, 22 number of wins

#Q3: Rank the teams based on the total number of wins in 2024.
SELECT Winner, COUNT(*)AS `Number of Wins`,
		RANK()OVER(ORDER BY COUNT(*) DESC) AS Rank_Assigned
FROM T20I
GROUP BY Winner

#

SELECT 
    Winner,
    COUNT(*) AS `Number of Wins`,
    DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS Rank_Assigned
FROM T20I
WHERE MatchDate LIKE '%2024'
    AND Winner NOT IN ('tied', 'no result')
GROUP BY Winner
ORDER BY `Number of Wins` DESC;


# Q4: Which team had the highest average winning margin (in runs), and what was the average margin?
SELECT *
FROM T20I
WHERE Margin LIKE '%runs'

#
SELECT *,
       LOCATE(' ', Margin) AS test
FROM T20I
WHERE Margin LIKE '%runs';

# 
SELECT *, SUBSTRING(Margin,1,LOCATE(' ', Margin) -1) AS test
FROM T20I
WHERE Margin LIKE '%runs';

# Find average 
SELECT 
    Winner,
    ROUND(
        AVG(
            CAST(
                SUBSTRING(Margin, 1, LOCATE(' ', Margin) - 1)
                AS SIGNED
            )
        ),
        2
    ) AS Avg_Margin
FROM T20I
WHERE Margin LIKE '%runs'
GROUP BY Winner
ORDER BY Avg_Margin DESC
LIMIT 1;
# Answer: India is a top winner

# winners in wickets
SELECT 
    Winner,
    ROUND(
        AVG(
            CAST(
                SUBSTRING(Margin, 1, LOCATE(' ', Margin) - 1)
                AS SIGNED
            )
        ),
        2
    ) AS Avg_Margin
FROM T20I
WHERE Margin LIKE '%wickets'
GROUP BY Winner
ORDER BY Avg_Margin DESC
LIMIT 1;

# Q5: List all matches where the winning margin was greater than the average margin across all matches. 
SELECT AVG(CAST(SUBSTRING(Margin, 1, LOCATE(' ', Margin) - 1) AS SIGNED)) AS Avg_Margin
FROM T20I
WHERE Margin LIKE '%runs'
# 34

WITH CTE_AVGMargin As(
SELECT AVG (CAST(SUBSTRING(Margin, 1, LOCATE(' ', Margin) - 1) AS SIGNED)) AS Avg_OverallMargin
FROM T20I
WHERE Margin LIKE '%runs'
)
SELECT T.Team1, T.Team2, T.Winner, T.Margin
FROM T20I T
LEFT JOIN CTE_AVGMargin A ON 1 = 1
WHERE T.Margin LIKE '%runs'
AND CAST(SUBSTRING(Margin, 1, LOCATE(' ', Margin) - 1) AS SIGNED) > A.Avg_OverallMargin

#Done

#Q6: Find the team with the most wins when chasing a target (wins by wickets)
SELECT*
FROM T20I

SELECT Winner, COUNT(*) AS WinWhileChasing
FROM T20I
WHERE Margin LIKE '%wickets'
AND Winner NOT IN ('tied', 'no result')
GROUP BY Winner

#Both rows
SELECT Winner, WinWhileChasing
FROM (
    SELECT 
        Winner, 
        COUNT(*) AS WinWhileChasing,
        RANK() OVER(ORDER BY COUNT(*) DESC) AS rk
    FROM T20I
    WHERE Margin LIKE '%wickets'
        AND Winner NOT IN ('tied', 'no result')
    GROUP BY Winner
) t;
WHERE rk= 1
# Q7: Head-to-Head record between 2 selected teams (England vs Australia)

SET @TeamA = 'England';
SET @TeamB = 'Australia';

SELECT *
FROM T20I
WHERE (Team1 = @TeamA AND Team2=@TeamB) OR (Team1 = @TeamA AND Team2=@TeamB)

# 

SET @TeamA = 'England';
SET @TeamB = 'Australia';

SELECT 
    Winner, 
    COUNT(*) AS Matches
FROM T20I
WHERE 
    (Team1 = @TeamA AND Team2 = @TeamB)
    OR
    (Team1 = @TeamB AND Team2 = @TeamA)
GROUP BY Winner;

SET @TeamA = 'India';
SET @TeamB = 'South Africa';

SELECT 
    Winner, 
    COUNT(*) AS Matches
FROM T20I
WHERE 
    (Team1 = @TeamA AND Team2 = @TeamB)
    OR 
    (Team1 = @TeamB AND Team2 = @TeamA)
GROUP BY Winner;

# Q8: Identify the month in 2024 with the highest number of I20I matches played
SELECT *
FROM T20I

SELECT 
    STR_TO_DATE(MatchDate, '%b %d, %Y') AS FullDate,
    YEAR(STR_TO_DATE(MatchDate, '%b %d, %Y')) AS YearPlayed,
    MONTH(STR_TO_DATE(MatchDate, '%b %d, %Y')) AS MonthNumber,
    MONTHNAME(STR_TO_DATE(MatchDate, '%b %d, %Y')) AS MonthName
FROM T20I
WHERE YEAR(STR_TO_DATE(MatchDate, '%b %d, %Y')) = 2024;
-- GROUP BY YEAR (MatchDate), 

# 
SELECT 
    YEAR(STR_TO_DATE(MatchDate, '%b %d, %Y')) AS YearPlayed,
    
    -- MONTH(STR_TO_DATE(MatchDate, '%b %d, %Y')) AS MonthNumber,
    
    MONTHNAME(STR_TO_DATE(MatchDate, '%b %d, %Y')) AS MonthName,
    
    COUNT(*) AS MatchesPlayed

FROM T20I

WHERE YEAR(STR_TO_DATE(MatchDate, '%b %d, %Y')) = 2024

GROUP BY 
    YEAR(STR_TO_DATE(MatchDate, '%b %d, %Y')),
    MONTH(STR_TO_DATE(MatchDate, '%b %d, %Y')),
    MONTHNAME(STR_TO_DATE(MatchDate, '%b %d, %Y'))

ORDER BY MatchesPlayed DESC;

# Q9: For each team, find how many matches they played in 2024 and their win percentage
SELECT *
FROM T20I

SELECT 
    Team,
    COUNT(*) AS MatchesPlayed,
    
    SUM(
        CASE 
            WHEN Team = Winner THEN 1
            ELSE 0
        END
    ) AS MatchesWon,

    ROUND(
        (
            SUM(
                CASE 
                    WHEN Team = Winner THEN 1
                    ELSE 0
                END
            ) * 100.0
        ) / COUNT(*),
        2
    ) AS WinPercentage

FROM (
    
    SELECT Team1 AS Team, Winner, MatchDate
    FROM T20I
    WHERE YEAR(STR_TO_DATE(MatchDate, '%b %d, %Y')) = 2024

    UNION ALL

    SELECT Team2 AS Team, Winner, MatchDate
    FROM T20I
    WHERE YEAR(STR_TO_DATE(MatchDate, '%b %d, %Y')) = 2024

) t

WHERE Winner NOT IN ('tied', 'no result')

GROUP BY Team

ORDER BY WinPercentage DESC;

# Q10: Identify the most successful team at each ground (team with most wins per ground)


WITH GroundWins AS (
    SELECT 
        Ground,
        Winner,
        COUNT(*) AS TotalWins
    FROM T20I
    WHERE Winner NOT IN ('tied', 'no result')
    GROUP BY Ground, Winner
),

RankedGrounds AS (
    SELECT 
        Ground,
        Winner,
        TotalWins,
        RANK() OVER (
            PARTITION BY Ground
            ORDER BY TotalWins DESC
        ) AS rk
    FROM GroundWins
)

SELECT 
    Ground,
    Winner AS MostSuccessfulTeam,
    TotalWins
FROM RankedGrounds
WHERE rk = 1
ORDER BY TotalWins DESC;