--Netflix project 


/*DROP TABLE IF EXISTS Netflix;
Create table Netflix (
show_id	varchar(6),
SHOW_type	VARCHAR(10),
title	VARCHAR(150),
director	VARCHAR(210),
shOW_cast	VARCHAR(850),
country	VARCHAR(250),
date_added	VARCHAR(50),
release_year	INT,
rating	VARCHAR(10),
duration	VARCHAR(15),
listed_in	VARCHAR(80),
description VARCHAR(300)
);
*/
SELECT * FROM NETFLIX

SELECT COUNT(*) AS TOTAL_RECORDS FROM NETFLIX

SELECT DISTINCT(SHOW_TYPE) FROM NETFLIX

-- 15 BUSINESS PROBLEMS

-- 1. COUNT THE NUMBER OF MOVIES vs TV SHOWS


SELECT SHOW_TYPE,COUNT(*) AS TOTAL_CONTENT FROM NETFLIX GROUP BY SHOW_TYPE;


-- 2. FIND THE MOST COMMON RATING FOR MOVIES AND TV SHOWS.


SELECT SHOW_TYPE,RATING AS TOTAL FROM
(
SELECT DISTINCT SHOW_TYPE, RATING, 
COUNT(*) AS TOTAL,
RANK() OVER (PARTITION BY SHOW_TYPE ORDER BY COUNT(*) DESC) AS RANKS
FROM NETFLIX  
GROUP BY SHOW_TYPE,RATING ORDER BY TOTAL DESC
)
AS T1
WHERE RANKS = 1 ;


-- 3. LIST ALL THE MOVIES RELEASED IN A SPECIFIC YEAR (E.G., 2020)

SELECT * FROM NETFLIX WHERE release_year = '2020' AND show_type ='Movie'

-- 4. FIND THE TOP 5 COUNTRIES WITH MOST CONTENT ON NETFLIX.

SELECT  
UNNEST(STRING_TO_ARRAY(COUNTRY,',')) AS NEW_COUNTRY,
COUNT(SHOW_ID) AS TOTAL FROM NETFLIX GROUP BY 1 ORDER BY TOTAL DESC LIMIT 5


--5. IDENTIFY THE LONGEST MOVIE

SELECT TITLE , 
SUBSTRING(DURATION,1,POSITION(' ' IN DURATION))::INT DURATION  
FROM NETFLIX WHERE show_type ='Movie'  AND DURATION IS NOT NULL
ORDER BY 2 DESC
LIMIT 1;


--6. FIND CONTENT ADDED IN LAST 5 YEARS.
Select *
from netflix 
where TO_DATE(date_added,'MONTH DD,YYYY') >= CURRENT_DATE - INTERVAL '5 YEARS';

-- 7. FIND ALL THE MOVIES\SHOWS BY DIRECTOR 'RAJIV CHILAKA'

SELECT *  FROM NETFLIX
WHERE  UPPER(DIRECTOR) LIKE '%RAJIV CHILAKA%' 


--8. LIST ALL SHOWS WITH MORE THAN 5 SEASONS


SELECT * FROM NETFLIX
WHERE show_type = 'TV Show' AND 
SUBSTRING(DURATION FROM 1 FOR 2)::NUMERIC  > 5;
--OR
SELECT * FROM NETFLIX 
WHERE show_type = 'TV Show' AND
SPLIT_PART(DURATION,' ',1)::NUMERIC > 5;


-- 9. COUNT THE NUMBER OF CONTENT ITEMS IN EACH GENRE

SELECT  
UNNEST(STRING_TO_ARRAY(listed_in,',')) AS GENRE , COUNT(*)
FROM NETFLIX
GROUP BY 1;


-- 10. FIND EACH YEAR AND THE AVERAGE NUMBERS OF CONTENT RELEASE BY INDIA ON NETFLIX
--     RETURN TOP 5 YEARS WITH HIGHEST AVERAGE CONTENT RELEASE.


SELECT 
EXTRACT (YEAR FROM(TO_DATE(date_added,'MONTH DD,YYYY'))) AS YEAR,
COUNT(*),
ROUND(COUNT(*)::NUMERIC/(SELECT COUNT(*) FROM NETFLIX WHERE COUNTRY ILIKE '%INDIA%')::NUMERIC * 100) AS avg_content
FROM NETFLIX
WHERE COUNTRY ILIKE '%INDIA%' 
GROUP BY EXTRACT (YEAR FROM(TO_DATE(date_added,'MONTH DD,YYYY')))
ORDER BY AVG_CONTENT DESC


-- 11. LIST ALL MOVIES THAT ARE DOCUMENTARIES

SELECT TITLE,LISTED_IN,* FROM NETFLIX
WHERE listed_in ILIKE '%Documentaries%'


-- 12. FIND ALL CONTENT WITHOUT A DIRECTOR

SELECT * FROM NETFLIX
WHERE NETFLIX.director IS NULL

-- 13. HOW MANY MOVIES ACTOR 'Salman Khan' APPEARED IN LAST 10 YEARS!

SELECT * FROM NETFLIX 
WHERE SHOW_CAST ILIKE '%Salman Khan%'
AND SHOW_TYPE = 'Movie' AND
release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10


-- 14. FIND THE TOP 10 ACTORS WHO HAVE APPEARED IN THE HIGHEST NUMBER OF MOVIES PRODUCED IN INDIA.

SELECT 
UNNEST(STRING_TO_ARRAY(SHOW_CAST,',')) AS ACTORS,
COUNT(*) AS TOTAL_MOVIES
FROM NETFLIX
WHERE COUNTRY ILIKE '%India%'
GROUP BY 1
ORDER BY TOTAL_MOVIES DESC
LIMIT 10


/* 15. CATEGORIZE THE CONTENT BASED ON THE PRESENCE OF THE KEYWORDS 'KILL' AND 'VIOLENCE' IN
       THE DESCRIPTION FIELD. LABEL CONTENT CONTAINING THESE KEYWORDS AS 'BAD' AND ALL OTHER
	   CONTENT AS GOOD. COUNT HOW MANY ITEMS FALL INTO EACH CATEGORY.  */

WITH T1
AS (
SELECT *,
CASE
WHEN 
NETFLIX.description ILIKE '%KILL%' OR NETFLIX.description ILIKE '%VIOLENCE%'
  THEN 'BAD_CONTENT'
  ELSE 'GOOD CONTEN'
END  AS CATEGORY
FROM NETFLIX
)
SELECT CATEGORY , COUNT(*) FROM T1 GROUP BY 1
--WHERE NETFLIX.description ILIKE '%KILL%' OR NETFLIX.description ILIKE '%VIOLENCE%'






