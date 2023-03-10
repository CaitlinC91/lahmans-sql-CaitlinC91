-- 1. What range of years for baseball games played does the provided database cover? 
SELECT MAX(yearID) AS latest_date,
		MIN(yearID) AS earliest_date
FROM Batting;

-- 2016	to 1871


-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
-- SELECT playerid, namefirst, namelast, height
-- FROM people
-- ORDER BY height;

--playerid -"gaedeed01", name-"Eddie""Gaedel", height - 43, teamid - SLA, teamname - St. Louis Browns, games played - 1

-- SELECT teamid, playerid, g_all
-- FROM appearances
-- WHERE playerid = 'gaedeed01'

--SELECT DISTINCT name
 --FROM teams
 --WHERE teamid = 'SLA';

SELECT CONCAT(p.namefirst,' ', p.namelast) AS name, 
	p.height, 
	a.g_all AS games_played,
	t.name AS team_name
FROM people AS p
	LEFT JOIN appearances AS a
	USING(playerid)
	INNER JOIN teams AS t
	ON a.teamid = t.teamid
ORDER BY p.height ASC
LIMIT 1;

--name -"Eddie Gaedel",	hieght - 43, games played - 1,	team - "St. Louis Browns"

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT p.namefirst, p.namelast, SUM(s.salary) AS total_salary
FROM people AS p
LEFT JOIN salaries AS s
USING (playerid)
WHERE playerid IN
	(SELECT playerid
		FROM collegeplaying
		WHERE schoolid = 
	(SELECT schoolid
		FROM schools
		WHERE schoolname = 'Vanderbilt University'))
GROUP BY p.namefirst, p.namelast
ORDER BY total_salary DESC;



-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT COUNT(*), -- should ahve sum instead!?!?!
CASE WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos = 'P' THEN 'Battery'
	WHEN pos = 'C' THEN 'Battery'
	ELSE 'Infield' END AS position
FROM fielding
WHERE yearid = '2016'
GROUP BY position

SELECT *
FROM fielding

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

--NEED TO AVG BY game and order by decade! sum of so / (sum of games/2)
SELECT 10*FLOOR(yearid/10) AS decade, ROUND(AVG(so),2)AS avg_strikeouts, ROUND(AVG(hr),2) AS avg_homeruns
FROM teams
WHERE yearid >= 1920
GROUP BY 10*FLOOR(yearid/10)
ORDER BY decade

--amount of strickout and homeruns has increased over time


-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

--may need sum?

SELECT namefirst, namelast, ROUND(((sb :: numeric / (sb :: numeric + cs :: numeric)) * 100),0) AS perc_stolen_base_attempts
FROM batting
LEFT JOIN people
USING (playerid)
WHERE (sb+cs) >= 20
	AND yearid = '2016'
ORDER BY perc_stolen_base_attempts DESC

-- "Chris"	"Owings"	91%

SELECT *
FROM batting

-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

 SELECT MAX(w)
 FROM teams
 WHERE yearid BETWEEN 1970 AND 2016
 	AND wswin = 'N'
-- 116 wins, loss ws

SELECT MIN(W)
 FROM Teams
 WHERE yearid BETWEEN 1970 AND 2016
 	AND wswin = 'Y'
 -- 63

 SELECT MIN(W)
 FROM Teams
 WHERE yearid BETWEEN 1970 AND 2016
 	AND yearid <> 1981
 	AND wswin = 'Y'
 --83 and won


-- SELECT *
-- FROM Teams
-- WHERE yearid BETWEEN 1970 AND 2016
-- 		AND wswin = 'Y'
-- ORDER BY g
-- --problem year 1981, not as many games played

-- TRYING to create a case when to evalute % wins by teams with most wins

WITH cte AS(SELECT COUNT(wswin) as wswins
			FROM teams
			WHERE yearid BETWEEN 1970 AND 2016
			AND wswin = 'Y'
		  )
		   

WITH cte AS (SELECT teamid, MAX(W) AS max_wins
  FROM teams
  WHERE yearID BETWEEN 1970 AND 2016 AND WSWin='Y'
  GROUP BY teamid)

SELECT COUNT(max_wins)
	/(SELECT COUNT(wswin) as count
			FROM teams
			WHERE yearid BETWEEN 1970 AND 2016
			AND wswin = 'Y'
		  ) AS perc
FROM teams
INNER JOIN cte
USING(teamid)
GROUP BY cte.teamid

 


SELECT yearid,
	AVG(CASE WHEN w = cte.max AND wswin = 'Y' THEN 1
	   WHEN w = cte.max AND wswin = 'N' THEN 0
	   END) AS pct_wins
FROM teams
INNER JOIN cte
USING(yearid)
WHERE yearid BETWEEN 1970 AND 2016
		AND yearid <> 1981
GROUP BY yearid
ORDER BY yearid

--this gives me a table of all max wins per year. I need to know when they also = Y in wswin and then, calculate %
SELECT COUNT(maxwins_wswinner) /
FROM
(SELECT teamid, MAX(w)
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
AND wswin = 'Y'
GROUP BY teamid) AS maxwins_wswinner


SELECT MAX(w), yearid
FROM teams
WHERE MAX(w) IN
		(SELECT wswin
			   FROM teams
			   WHERE wswin = 'Y'
			)
			AND yearid BETWEEN 1970 AND 2016
GROUP BY yearid



SELECT
	teamid,
	MAX(w), 
	MAX(MAX(w)) OVER(PARTITION BY yearid) AS max_window
FROM teams
WHERE wswin='Y' 
AND yearid BETWEEN '1970' AND '2016'
GROUP BY yearid, name, w
ORDER BY yearid;

SELECT teamid, yearid, wswin, w
FROM teams
WHERE yearid BETWEEN '1970' AND '2016'
ORDER BY teamid


WITH champ_wins AS (
  SELECT teamid, MAX(W) AS max_wins
  FROM teams
  WHERE yearID BETWEEN 1970 AND 2016 AND WSWin='Y'
  GROUP BY teamid)
	
SELECT teamid, MAX(W) AS max_wins
  FROM teams
  WHERE yearID BETWEEN 1970 AND 2016 AND WSWin='Y'
  GROUP BY teamid
  ORDER BY teamid
  
-- below query returns correct numbers!**************************************************************

WITH max_wins AS (
  SELECT MAX(w) AS max_wins, yearid
  FROM teams
  WHERE yearid BETWEEN 1970 AND 2016
  GROUP BY yearid
)--create a CTE to show the team with the max wins--this runs first
SELECT
  COUNT(*) AS num_champs, --calculates the number of championship wins for the team with the most wins by using a row count
  COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT yearid) FROM teams WHERE yearid BETWEEN 1970 AND 2016) AS percentage---calculate the percentage of championship wins for the teams with the most wins and then divdes the # of championship wins by the total number of years--this runs last
FROM (
  SELECT teams.teamid, teams.yearid
  FROM teams
  INNER JOIN max_wins
  ON teams.yearid = max_wins.yearid AND teams.w = max_wins.max_wins
  WHERE teams.wswin = 'Y'
) AS champ_wins;
--this runs second and creates a wins the worldseries section----  

--Walk through. cte pulling name, win, year ,and wswin from teams.


-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

--Need to add names for team.
SELECT park_name, team, SUM(attendance)/ SUM(games) AS avg_attendance, 'Top five' AS attendance
FROM homegames AS h
LEFT JOIN parks AS p
USING (park)
WHERE year = '2016'
	AND games > 10
GROUP BY park_name, team
ORDER BY avg_attendance DESC
LIMIT 5


-- "LOS03"	"LAN"	45719
-- "STL10"	"SLN"	42524
-- "TOR02"	"TOR"	41877
-- "SFO03"	"SFN"	41546
-- "CHI11"	"CHN"	39906

SELECT park_name, team, SUM(attendance)/ SUM(games) AS avg_attendance, 'Lowest five' AS attendance
FROM homegames AS h
LEFT JOIN parks AS p
USING (park)
WHERE year = '2016'
	AND games > 10
GROUP BY park_name, team
ORDER BY avg_attendance
LIMIT 5

-- "STP01"	"TBA"	15878
-- "OAK01"	"OAK"	18784
-- "CLE08"	"CLE"	19650
-- "MIA02"	"MIA"	21405
-- "CHI12"	"CHA"	21559

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

SELECT DISTINCT b.yearid, a.playerid
FROM awardsmanagers AS a
LEFT JOIN awardsmanagers as b
USING (playerid)
WHERE a.awardid = 'TSN Manager of the Year'
	AND a.lgid <> 'ML'
GROUP BY a.playerid, b.yearid
HAVING COUNT(DISTINCT a.lgid) >=2  



--QUERY RETURNS correct playerids
SELECT DISTINCT b.yearid, a.playerid, COUNT(DISTINCT a.lgid)
FROM awardsmanagers AS a
LEFT JOIN awardsmanagers as b
USING (playerid)
WHERE a.awardid = 'TSN Manager of the Year'
	AND a.lgid <> 'ML'
GROUP BY a.playerid, b.yearid
HAVING COUNT(DISTINCT a.lgid) >=2

--QUERY RETURNS CORRECT NAMES



SELECT p.namefirst, p.namelast , m.teamid
FROM 
	(SELECT playerid, COUNT(DISTINCT lgid)
		FROM awardsmanagers AS a
		WHERE awardid = 'TSN Manager of the Year'
		AND lgid <> 'ML'
		GROUP BY playerid
		HAVING COUNT(DISTINCT lgid) >=2) AS manager
LEFT JOIN people as p
USING(playerid)
LEFT JOIN managers as m
USING(playerid)




SELECT yearid, teamid ,playerid
FROM managers
WHERE yearid BETWEEN 1997 AND 2012
AND playerid = 'johnsda02'

SELECT *
FROM awardsmanagers
WHERE playerid = 'johnsda02'


-- RETURNS NAMES, YEARS, NEED TO ADD TEAMS

SELECT DISTINCT manager.yearid, p.namefirst, p.namelast , t.name
FROM 
	(SELECT a.playerid, COUNT(DISTINCT a.lgid), b.yearid
		FROM awardsmanagers AS a
		LEFT JOIN awardsmanagers as b
		USING (playerid)
		WHERE a.awardid = 'TSN Manager of the Year'
			AND a.lgid <> 'ML'
		GROUP BY a.playerid, b.yearid
		HAVING COUNT(DISTINCT a.lgid)>=2) AS manager
LEFT JOIN people as p
USING(playerid)
LEFT JOIN teams as t
ON manager.yearid = t.yearid





-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.



SELECT 
  playerID, 
  MAX(HR) AS career_high_hr,
  CONCAT(p.namelast,',', p.namefirst) AS name
FROM 
  Batting AS b
LEFT JOIN people AS p
USING(playerid)
WHERE playerid IN
	(SELECT 
		playerid
	 FROM batting
	WHERE yearid = '2016')
GROUP BY 
  playerID, name
HAVING 
  COUNT(DISTINCT yearID) >= 10
  AND MAX(hr) >=1
ORDER BY playerid




(SELECT 
	yearid,
	 playerid,
	 hr
FROM batting
WHERE yearid = '2016')



		




-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

--cte lag info for salary to calculate % change 
WITH yearly_salary_lag AS (SELECT yearid, teamid, SUM(salary) AS team_salary,
	LAG(SUM(salary)) OVER (PARTITION BY teamid ORDER BY yearid) AS previous_year_salary
FROM salaries
WHERE yearid >= 2000
GROUP BY yearid, teamid
),
 -- cte lag info for win to cal % change
 yearly_wins_lag AS (
	SELECT yearid, teamid, w,
	LAG(w) OVER (PARTITION BY teamid ORDER BY yearid) AS previous_yr_wins
	FROM teams
	WHERE yearid >= 2000
)

--query calculating % change, per year per team. May need to query an avg change over time to be able to compare.
SELECT *,
	 COALESCE(ROUND((team_salary - previous_year_salary) /previous_year_salary * 100),0) AS perc_change_salary,
	 COALESCE(ROUND(((w :: FLOAT) -previous_yr_wins)/ previous_yr_wins * 100),0) AS perc_change_wins
FROM yearly_salary_lag
LEFT JOIN yearly_wins_lag
USING(yearid, teamid) 

-- 12. In this question, you will explore the connection between number of wins and attendance.
--     <ol type="a">
--       <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
--       <li>Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.</li>
--     </ol>


-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?
