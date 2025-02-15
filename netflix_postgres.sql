-- Netflix Project

CREATE TABLE netflix_ (
    show_id VARCHAR(6),
    type_ VARCHAR(10),
    title VARCHAR(150),
    director VARCHAR(210),
    cast_ VARCHAR(1000),
    country VARCHAR(150),
    date_added VARCHAR(100),
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(20),
    listed_in VARCHAR(500),  
    description_ VARCHAR(250)
);

SELECT * FROM netflix_;

SELECT 
	COUNT(*) as total_content
FROM netflix_;

SELECT DISTINCT type_
FROM netflix_; 

-- Q1. Count the number of Movies vs TV Shows

SELECT 
	COUNT (CASE WHEN type_ = 'Movie' THEN 1 END) as number_of_movies,
	COUNT (CASE WHEN type_ = 'TV Show' THEN 1 END) as number_of_tv_shows
FROM netflix_;

-- OR 

SELECT type_,
	COUNT(*) as total_content
FROM netflix_
GROUP BY type_;

-- Q2. Find the most common rating for Movies and TV shows

SELECT
	type_,
	rating
FROM 

	(SELECT 
		type_,
		rating,
		COUNT (*),
		RANK () OVER(PARTITION BY type_ ORDER BY COUNT(*) DESC) as ranking
	FROM netflix_
	GROUP BY 1, 2 ) as t1
WHERE ranking = 1

--Q3. List all movies released in a specific year (e.g., 2020)

SELECT * FROM netflix_
 WHERE 
 	type_  = 'Movie'
	 AND release_year = 2020;

-- Q4. Find the top 5 countries with the most content on Netflix



SELECT 
	UNNEST (STRING_TO_ARRAY(country, ',')) as new_country,
	COUNT(show_id) AS total_content
FROM netflix_
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

--Q5. Identify the longest movie or TV show duration

SELECT title, duration, 
       CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) AS duration_in_minutes
FROM netflix_
WHERE type_ = 'Movie' AND duration IS NOT null
ORDER BY duration_in_minutes DESC
;

-- for TV show

SELECT title, duration, 
       CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) AS number_of_seasons
FROM netflix_
WHERE type_ = 'TV Show' AND duration IS NOT null
ORDER BY number_of_seasons DESC
LIMIT 5
;

--Q6. Find content added in the last 5 years

SELECT 	*
FROM netflix_
WHERE 
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

--Q7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM netflix_
WHERE director ILIKE '%Rajiv Chilaka%';

--Q8. List all TV shows with more than 5 seasons

SELECT title, duration, 
       CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) AS number_of_seasons
FROM netflix_
WHERE type_ = 'TV Show' AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5
ORDER BY number_of_seasons DESC

--Q9. Count the number of content items in each genre

SELECT 
	UNNEST (STRING_TO_ARRAY(listed_in, ',')) as new_genres,
	COUNT(show_id) AS total_content
FROM netflix_
GROUP BY 1
ORDER BY 2 DESC

-- Q10. Find the average release year for content produced in India. return top 5 
-- year with highest avg content release
-- we need avg highest content/total number of content 
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
	COUNT(*) as yearly_content,
	ROUND(	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix_ WHERE country = 'India') * 100, 2 
) as avg_content_per_year
FROM netflix_
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

--Q11. List all movies that are documentaries

SELECT *,
type_,
listed_in
FROM netflix_
WHERE 
	type_ = 'Movie'
	AND 
	listed_in ILIKE '%Documentaries%'

--Q12. Find all content without a director

SELECT *
FROM netflix_
WHERE director IS NULL

--Q13. Find how many movies actor 'Salman Khan' appeared in the last 10 years!

SELECT *
FROM netflix_
WHERE 
	cast_ ILIKE '%Salman Khan%'

--Q14. Find the top 10 actors who have appeared in the highest number of movies produced in India

SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(cast_, ','))) as actors_list,
	COUNT(*) as total_content
FROM netflix_
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

--Q15. Categorise the content based on the presence of the keywords 'kill' 
--and 'violence' in description field. Label content containing keywords as
--'Bad' & all other content as 'Good'. Content how many items fall into each 
--category.


WITH new_table
AS 
(
SELECT *,
    CASE 
        WHEN description_ ILIKE '%kill%' OR description_ ILIKE '%violence%' 
        THEN 'Bad Content'
        ELSE 'Good Content'
    END AS category
FROM netflix_
)
SELECT 
	category,
	COUNT(*) as total_content
FROM new_table
GROUP BY 1

	