# Netflix Movies & TV Shows Data Analytics using SQL

![Netflix logo](https://github.com/UmangUpadhyay1/Netflix_SQL_Project/blob/main/pngwing.com.png)

## Overview
This project focuses on an in-depth analysis of Netflix's movies and TV shows data using SQL. The aim is to uncover valuable insights and address various business questions derived from the dataset. The following README outlines the project's objectives, business challenges, solutions, key findings, and conclusions.

## Objectives

- Examine the proportion of movies to TV shows in the content library.
- Determine the prevalent ratings for both movies and TV shows.
- Review and assess content by release year, country, and duration.
- Investigate and classify content using specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS Netflix;
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
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT SHOW_TYPE,COUNT(*) AS TOTAL_CONTENT FROM NETFLIX GROUP BY SHOW_TYPE;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * FROM NETFLIX WHERE release_year = '2020' AND show_type ='Movie'
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT  
UNNEST(STRING_TO_ARRAY(COUNTRY,',')) AS NEW_COUNTRY,
COUNT(SHOW_ID) AS TOTAL FROM NETFLIX GROUP BY 1 ORDER BY TOTAL DESC LIMIT 5
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT TITLE , 
SUBSTRING(DURATION,1,POSITION(' ' IN DURATION))::INT DURATION  
FROM NETFLIX WHERE show_type ='Movie'  AND DURATION IS NOT NULL
ORDER BY 2 DESC
LIMIT 1;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
Select *
from netflix 
where TO_DATE(date_added,'MONTH DD,YYYY') >= CURRENT_DATE - INTERVAL '5 YEARS';
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *  FROM NETFLIX
WHERE  UPPER(DIRECTOR) LIKE '%RAJIV CHILAKA%'
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT * FROM NETFLIX
WHERE show_type = 'TV Show' AND 
SUBSTRING(DURATION FROM 1 FOR 2)::NUMERIC  > 5;
--OR
SELECT * FROM NETFLIX 
WHERE show_type = 'TV Show' AND
SPLIT_PART(DURATION,' ',1)::NUMERIC > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT  
UNNEST(STRING_TO_ARRAY(listed_in,',')) AS GENRE , COUNT(*)
FROM NETFLIX
GROUP BY 1;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT 
EXTRACT (YEAR FROM(TO_DATE(date_added,'MONTH DD,YYYY'))) AS YEAR,
COUNT(*),
ROUND(COUNT(*)::NUMERIC/(SELECT COUNT(*) FROM NETFLIX WHERE COUNTRY ILIKE '%INDIA%')::NUMERIC * 100) AS avg_content
FROM NETFLIX
WHERE COUNTRY ILIKE '%INDIA%' 
GROUP BY EXTRACT (YEAR FROM(TO_DATE(date_added,'MONTH DD,YYYY')))
ORDER BY AVG_CONTENT DESC
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT TITLE,LISTED_IN,* FROM NETFLIX
WHERE listed_in ILIKE '%Documentaries%'
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * FROM NETFLIX
WHERE NETFLIX.director IS NULL
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT * FROM NETFLIX 
WHERE SHOW_CAST ILIKE '%Salman Khan%'
AND SHOW_TYPE = 'Movie' AND
release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT 
UNNEST(STRING_TO_ARRAY(SHOW_CAST,',')) AS ACTORS,
COUNT(*) AS TOTAL_MOVIES
FROM NETFLIX
WHERE COUNTRY ILIKE '%India%'
GROUP BY 1
ORDER BY TOTAL_MOVIES DESC
LIMIT 10
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.
