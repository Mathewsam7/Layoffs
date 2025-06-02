-- Exploratory Data Analysis

select *
from layoff_staging_2;

-- Lets see the max layoffs and percentage 

select max(Total_laid_off), max(percentage_laid_off)
from Layoff_staging_2;

-- All values in total_laid_off order where percentage of laid is 100
select *
from Layoff_staging_2
where percentage_laid_off =1
order by total_laid_off desc;

-- same but order by funds raised in millions 
SELECT *
from Layoff_staging_2
where percentage_laid_off =1
order by funds_raised_millions desc;

-- To see the sum of laid off based on company

select company, sum(total_laid_off)
from Layoff_staging_2
group by company
order by 2 desc;
-- 2 represents column number

-- With this  query , used to find the earliest and latest layoff event dates recorded in the table.
select Min(`date`), Max(`date`)
from Layoff_staging_2;

-- To see the sum of laid off based on industry

select industry , sum(total_laid_off)
from Layoff_staging_2
group by industry
order by 2 desc;

-- To see the sum of laid off based on Country
select country , sum(total_laid_off)
from Layoff_staging_2
group by country
order by 2 desc;


-- To see the sum of laid off based on date
select `date` , sum(total_laid_off)
from Layoff_staging_2
group by `date`
order by 1 desc;

-- Based on year 
select year(`date`) , sum(total_laid_off)
from Layoff_staging_2
group by year(`date`)
order by 1 desc;

-- Based on stages
select stage , sum(total_laid_off)
from Layoff_staging_2
group by stage
order by 2 desc;

-- Rolling total

select substring(`date`,1,7) as `Month` , sum(total_laid_off)
from Layoff_staging_2
where substring(`date`,1,7) is not null
group by substring(`date`,1,7)
order by 1 asc;

with Rolling_total as
(
select substring(`date`,1,7) as `Month` , sum(total_laid_off) as Total_off
from Layoff_staging_2
where substring(`date`,1,7) is not null
group by substring(`date`,1,7)
order by 1 asc
)
select `Month` ,total_off,
 sum(total_off) over (order by `Month`) as rolling_total
from Rolling_total;

-- Based on company 
select company,year(`date`), sum(total_laid_off)
from Layoff_staging_2
group by company ,year(`date`)
order by 3 desc;

-- rolling total based on company

with Company_year (Company, years, total_laid_off) as
(
select company,year(`date`), sum(total_laid_off)
from Layoff_staging_2
group by company ,year(`date`)
) , Company_year_rank as
(select *, 
dense_rank() over(partition by years order by total_laid_off desc) as Ranking
from Company_year
where years is not null
)
select *
from Company_year_rank
where Ranking <=5;
-- This find the top 5 companies with the most layoffs each year.