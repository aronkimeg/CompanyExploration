/* 
Title: Company Layoff Exploratory Analysis
Author: Aron Kim
Date: 12/06/2024

This is the second part of the layoff project where exploratory analysis will be done
*/



-- Looking at what I'm working with

SELECT *
FROM layoffs_copy2;


-- Looking at the total amount of people laid off and also in a company
-- Seems like there is at least one company that lost all their members

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_copy2;

-- Diving deeper into companies that have lost all their workers
-- There are a lot more companies that have lost all their workers than I thought
-- Also interesting how big companies like Britishvolt that have raised $2.4 billion could also lose their company
SELECT *
FROM layoffs_copy2
WHERE percentage_laid_off = 1
ORDER BY funds_raised DESC;


-- Well known companies like Amazon seem to lay off more workers. II am assuming that it's because of the large amount of workers they have.
SELECT company, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY company
ORDER BY 2 DESC;

-- Checking date to see which time frame these layoffs were happening
-- Almost 5 year span
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_copy2 ;


-- Finding the average of the percent layoffs depending on the stage
-- The data shows that startup seeds have the most proportionately and as the series of layoffs continue the number of layoffs are less
SELECT stage, ROUND(AVG(percentage_laid_off),2)
FROM layoffs_copy2
GROUP BY stage
ORDER BY 2 DESC;

-- Transportation industry seems to have laid off the most people and industries like AI, Legal, and Manufacturing seem to have the least
SELECT industry, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY industry
ORDER BY 2 DESC;

/* 
Though transportation had the biggest amount of people laid off, industries such as finance and healthcare
seem to have lost the most in proportion to the amount of workers that they have.
Industries such as AI and manufacturing seem to have the smallest percentage of people laid off.
 */
SELECT industry, SUM(total_laid_off), SUM(percentage_laid_off)
FROM layoffs_copy2
GROUP BY industry
ORDER BY 3 DESC;


-- Seeing which countries has most layoffs
SELECT country, sum(total_laid_off)
FROM layoffs_copy2
GROUP BY country
ORDER BY 2 DESC;

-- Checking if date might have correlation to layoffs
SELECT `date`, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY `date`
ORDER BY 2 DESC;

-- Checking correlation between total laid off and specific years
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

-- Checking if stage has to do with layoffs
SELECT stage, sum(total_laid_off)
FROM layoffs_copy2
GROUP BY stage
ORDER BY 2 DESC;

-- Seeing if total laid off is in proportion to their workers
SELECT stage, sum(percentage_laid_off)
FROM layoffs_copy2
GROUP BY stage
ORDER BY 2 DESC;

-- Finding rolling sum based on year and month of date
-- The sum of people being laid off each month of the year is being added towards the rolling total
-- Can see that a lot of people started losing their jobs around the time covid happened
SELECT substring(`date`,1,7) as `month_year`, SUM(total_laid_off)
FROM layoffs_copy2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `month_year`
ORDER BY 1 ASC;

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) as `month_year`, SUM(total_laid_off) as sum_laidoff
FROM layoffs_copy2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month_year`
ORDER BY 1 ASC
)
SELECT `month_year`, sum_laidoff, SUM(sum_laidoff) OVER(ORDER BY `month_year`) as rolling_total
FROM Rolling_Total;


-- Seeing each company by each year of the date and the amount of people that they laid off
SELECT company, YEAR(`date`) as `Year`, SUM(total_laid_off) as sum_laidoff
FROM layoffs_copy2
GROUP BY company, `year`
ORDER BY 3 DESC;

-- Created two CTEs to include a ranking system for each year
-- The ranking system ranks the top five companies that laid off the most people in each year
WITH Company_year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`) as `Year`, SUM(total_laid_off)
FROM layoffs_copy2
GROUP BY company, `Year`
), Company_Year_Rank AS
(SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) as Ranking
FROM Company_year
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;


