-- ## Lahman Baseball Database Exercise
-- - this data has been made available [online](http://www.seanlahman.com/baseball-archive/statistics/) by Sean Lahman
-- - you can find a data dictionary [here](http://www.seanlahman.com/files/database/readme2016.txt)

-- ### Use SQL queries to find answers to the *Initial Questions*. If time permits, choose one (or more) of the *Open-Ended Questions*. Toward the end of the bootcamp, we will revisit this data if time 
SELECT so
FROM teams
 
SELECT COUNT(g/2)
FROM teams

SELECT MIN(height), namelast
FROM people
GROUP BY namelast, height
ORDER BY height ASC

-- **Initial Questions**

-- 1. What range of years for baseball games played does the provided database cover? 
SELECT MAX(year), MIN(year)
FROM homegames

The database covers games played from 1871 - 2016
-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT namefirst,namelast, MIN(height) AS height, a.g_all AS games_played, t.name
FROM people AS p
LEFT JOIN appearances AS a
USING(playerid)
LEFT JOIN teams AS t
USING(teamid)
GROUP BY namefirst,namelast, t.name, g_all
ORDER BY height ASC
LIMIT 1

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT namefirst AS first_name , namelast AS last_name , SUM(salary) ::numeric :: money AS total_salary
FROM people
INNER JOIN salaries
USING(playerid)
WHERE playerid IN (SELECT playerid
	  FROM people
	  LEFT JOIN salaries
	  USING(playerid)
	  INTERSECT 
	  SELECT playerid
	  FROM collegeplaying
	  LEFT JOIN schools
	  USING(schoolid)
	  WHERE schoolname = 'Vanderbilt University')
GROUP BY namefirst, namelast
ORDER BY SUM(salary) DESC
David Price earned the most money($81,851,296)
-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
SELECT SUM(PO) AS put_outs, yearid, 
           (CASE WHEN pos = 'OF' THEN 'Outfield'
		   WHEN pos = 'SS'  THEN 'Infield'
		   WHEN pos = '1B' THEN 'Infield'
		   WHEN pos = '2B' THEN 'Infield'
		   WHEN pos = '3B' THEN 'Infield'
		   ELSE 'Battery' END ) AS position
FROM fielding
WHERE yearid = '2016'
GROUP BY position, yearid
 

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
SELECT ROUND(SUM(so) :: numeric/ SUM(g/2) :: numeric , 2) AS avg_strikeouts, ROUND(SUM(hr) :: numeric/ SUM(g/2) :: numeric , 2) AS avg_homeruns,
       (CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
	   WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
	   WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
	   WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
	   WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
	   WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
	   WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
	   WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
	   WHEN yearid BETWEEN 2000 AND 2010 THEN '2000s'
	   ELSE '2010s' END) AS decade
FROM teams
WHERE yearid >= 1920 
GROUP BY decade
ORDER BY decade DESC
There has been an increase in the average of strikeouts and home runs.
-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.
SELECT CONCAT(namefirst, ' ', namelast) AS name, 
SUM(sb) AS stolenbase,
SUM(cs) AS caught_stealing,
SUM(sb+cs) AS attempted, 
CONCAT(ROUND(SUM(sb)/ SUM(sb + cs):: numeric  * 100 , 2), '%') AS percent_stolen 
FROM batting 
LEFT JOIN people AS p
USING(playerid)
WHERE yearid = 2016 AND sb+cs >= 20
GROUP BY name
ORDER BY percent_stolen DESC

The player with the most success stealing bases was Chris Owings with a success rate of 91.30%.


-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
most_wins_no_ws AS (SELECT name, w, wswin, yearid
						FROM teams
						WHERE yearid BETWEEN 1970 AND 2016
						AND wswin = 'N'
						AND yearid =! 1981
						ORDER BY w DESC
						LIMIT 1),
				lowest_wins_ws AS (SELECT name, w, wswin, yearid
								   FROM teams
								   WHERE yearid BETWEEN 1970 AND 2016
								   AND wswin = 'Y'
								   AND yearid =! 1981
								   ORDER BY w DESC
								   LIMIT 1)
								   
SELECT *
FROM most_wins_no_ws
UNION ALL
SELECT *
FROM lowest_wins_ws

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
SELECT park_name, h.team, t.name, (h.attendance/h.games) AS avg_attendance
FROM homegames AS h
JOIN parks AS p
USING (park)
JOIN teams AS t
ON h.team = t.teamid AND h.year = t.yearid
WHERE year = 2016
AND games >= 10
ORDER BY avg_attendance ASC
LIMIT 5

SELECT park_name, h.team, t.name, (h.attendance/h.games) AS avg_attendance
FROM homegames AS h
JOIN parks AS p
USING (park)
JOIN teams AS t
ON h.team = t.teamid AND h.year = t.yearid
WHERE year = 2016
AND games >= 10
ORDER BY avg_attendance DESC
LIMIT 5
-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
SELECT namegiven,t.name
FROM people
LEFT JOIN awardsmanagers AS am
USING(playerid)
LEFT JOIN teams AS t
ON am.yearid = t.yearid
WHERE am.lgid LIKE 'NL' AND am.lgid LIKE 'AL' 
GROUP BY namegiven, t.name, am.awardid
HAVING am.awardid LIKE 'TSN Manager of the Year'


-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
SELECT MAX(hr), namefirst, namelast, DATE_PART(year, (AGE(span_last , span_first) :: date)) AS yearsinleague
FROM batting AS b
LEFT JOIN people AS p
USING(playerid)
LEFT JOIN homegames AS hg
ON b.yearid = hg.year
WHERE yearid = 2016 AND hr >= 1 
GROUP BY p.namefirst, p.namelast, yearsinleague


SELECT span_first, span_last,  
FROM homegames

-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

-- 12. In this question, you will explore the connection between number of wins and attendance.
--     <ol type="a">
--       <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
--       <li>Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.</li>
--     </ol>


-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

SELECT
  yearid/10*10 AS decade,
  ROUND(AVG(so)::numeric, 2) AS avg_strikeouts_per_game,
  ROUND(AVG(hr)::numeric, 2) AS avg_home_runs_per_game
FROM
  pitchingpost
WHERE
  yearid >= 1920
GROUP BY
  decade
ORDER BY
  decade;
  
SELECT lgid 
FROM awardsmanagers
  
  
SELECT attendance
FROM homegames
WHERE year = 2016

SELECT awardid
FROM awardsmanagers

SELECT stint 
FROM batting