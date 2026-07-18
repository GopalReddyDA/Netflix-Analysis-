/*
 Project      : Netflix Data Analysis using SQL
 Dataset      : Netflix Dataset
 -----------------------------------------------
*/

/*
 SECTION 1 : Data Exploration
 Purpose    : Understand the structure and contents of the dataset.
 -------------------------------------------------------------------
*/

-- 1.1 Preview the Dataset
SELECT *
FROM netflix;


-- 1.2 Total Number of Records
-- Expected Result: 8,807 Records

SELECT COUNT(*) AS total_records
FROM netflix;


-- 1.3 Identify Available Content Types
-- Expected Result:
-- Movie
-- TV Show

SELECT DISTINCT type
FROM netflix;


-- 1.4 Check Available Release Years
-- Observation:
-- Content ranges from 1925 to 2021.

SELECT DISTINCT release_year
FROM netflix
ORDER BY release_year DESC;


-- 1.5 Identify Date Added Range by Release Year
-- Purpose:
-- Understand when titles from each release year were added to Netflix.

SELECT
    release_year,
    MIN(date_added) AS first_added_date,
    MAX(date_added) AS last_added_date
FROM netflix
GROUP BY release_year
ORDER BY release_year;


/*
 SECTION 2 : Content Distribution Analysis
 Purpose    : Analyze the distribution of Movies and TV Shows.
==============================================================*/

-- Business Question 1
-- Q1.Count the Number of Movies vs TV Shows

-- Movie   : 6,131
-- TV Show : 2,676

SELECT
    type,
    COUNT(*) AS total_titles
FROM netflix
GROUP BY type;

-- Q2.Find the most common rating for movies and TV shows
WITH cte as (
SELECT  
	type,
	rating,
	COUNT(*)AS common_rating_count
FROM netflix  
GROUP BY type,rating )
,cte2 as (
SELECT 
	type,
	rating,
	common_rating_count,
	RANK()OVER(PARTITION BY type ORDER BY common_rating_count DESC ) AS rn
FROM cte )

SELECT 
	type,
	rating,
	common_rating_count
FROM cte2 WHERE rn =1


-- Q3.List all movies released in a specific year (e.g., 2020)

-- Filter =2020
-- type ='Movie'
SELECT
	*
FROM netflix
WHERE release_year =2020
	and type ='Movie'

-- Q4.Find the top 5 countries with the most content on Netflix
-- Filter Top =5 
-- countries 

SELECT 
	UNNEST(STRING_TO_ARRAY(country,','))AS new_country ,
	COUNT(*)AS total_content 
FROM netflix 
GROUP BY country
ORDER BY total_content DESC 
LIMIT 5  


-- Q5.Identify the longest movie
SELECT *
FROM netflix 
where type ='Movie'
	and duration = (select max(duration)from netflix)
limit 1


-- Q6.Find content added in the last 5 years
select 
	*
from netflix
where to_date(date_added,'MONTH DD,YYYY')>=current_date -interval '5 years'



-- Q7.Find all the movies/TV shows by director 'Rajiv Chilaka'!
Select * 
from netflix 
where director like '%Rajiv Chilaka%'


--Q8.List all TV shows with more than 5 seasons 
select *
from netflix
where type ='TV Show'
and SPLIT_PART(duration,' ',1)::NUMERIC > 5 



-- Q9.Count the number of content items in each genre
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in,','))AS genre,
	COUNT(show_id)AS total_content
FROM netflix 
GROUP BY genre 

-- Q10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!

SELECT
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    COUNT(*) AS yearly_content,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM netflix WHERE country = 'India'),
        2
    ) AS avg_content_release
FROM netflix
WHERE country = 'India'
  AND date_added IS NOT NULL
GROUP BY year
ORDER BY avg_content_release DESC
LIMIT 5;


-- Q11.List all movies that are documentaries
SELECT *
FROM netflix 
WHERE listed_in ILIKE '%Documentaries%'


-- Q12.Find all content without a director
SELECT *
FROM netflix 
WHERE director ISNULL

-- Q13.Find how many movies actor 'Salman Khan' appeared in last 10 years
SELECT *
FROM netflix 
WHERE 
	cast_members ILIKE '%Salman Khan%'
AND release_year > EXTRACT (YEAR FROM CURRENT_DATE) -10


-- Q14.Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
	UNNEST(STRING_TO_ARRAY(cast_members, ','))as actors,
	COUNT(*)AS total_content
FROM netflix 
WHERE country ILIKE '%India'
GROUP BY actors 
ORDER BY total_content DESC 
LIMIT 10

/*--15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/
SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category,type
ORDER BY type



