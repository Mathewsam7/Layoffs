select * 
from layoffs;

-- Data Cleaning
-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null values or Blank values
-- 4. Remove any Columns

create Table Layoff_staging
Like layoffs;

select * 
from Layoff_staging;
-- I perfomed this in case if I made any error during the process. So my intention is to make a duplicate table.
Insert layoff_staging
Select * 
from layoffs;

select * 
from Layoff_staging;

-- 1.Remove Duplicates
-- Here , I am going to find any duplicates using query below ,so I made a new row_num .
-- By this query , I can see if value > 1 , then it means it has duplicates.

select * ,
row_number() over (
 partition by company,industry,total_laid_off,percentage_laid_off,'date') as Row_Num
from Layoff_staging;

-- I am using CTEs for finding duplicates

with duplicate_cte as
(select * ,
row_number() over (
 partition by company,industry,total_laid_off,percentage_laid_off,'date') as Row_Num
from Layoff_staging
)
select * 
from duplicate_cte
where row_num > 1;

select *
from Layoff_staging;

-- i am creating another table with row_num

CREATE TABLE `Layoff_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL ,
  `row_numb` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from Layoff_staging_2;

Insert into layoff_staging_2
select * ,
row_number() over (
 partition by company,industry,total_laid_off,percentage_laid_off,'date') as Row_Num
from Layoff_staging;

select *
from layoff_staging_2
where row_numb > 1;

delete
from layoff_staging_2
where row_numb > 1
limit 1000;

-- Standardizing the data

select *
from Layoff_staging_2;

select Distinct(company)
from Layoff_staging_2;

select company, trim(company)
from Layoff_staging_2;

update Layoff_staging_2
set company = trim(company)
limit 1000;

-- Above query is made so that we trim the data with blank spaces

select distinct industry
from Layoff_staging_2
order by 1;

select distinct country
from Layoff_staging_2;

select distinct country, trim(trailing '.' from country)
from Layoff_staging_2;

update Layoff_staging_2
set country = trim(trailing '.' from country)
where country like 'United States%'
limit 1000;
-- Here we used trim , but its not just a blank space but a '.' . For this we used trailing function

-- Next we need to change the date format from string to date 
select `date` , str_to_date(`date`,'%m/%d/%Y')
from Layoff_staging_2;

update Layoff_staging_2
set `date` = str_to_date(`date`, '%Y/%d/%m')
limit 1000;

UPDATE Layoff_staging_2
SET `date` = CASE
    WHEN `date` LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(`date`, '%c/%e/%Y'), '%Y-%m-%d')
    ELSE `date`
END;
-- When i used limit ,all data was not able to change , so i did an update with case statement 
select `date`
from Layoff_staging_2;

-- date is still showing as text , so i used alter table 

ALTER TABLE Layoff_staging_2
MODIFY COLUMN `date` DATE;

select *
from Layoff_staging_2;
-- 
select *
from Layoff_staging_2
where total_laid_off is Null
and percentage_laid_off is null;

update Layoff_staging_2
set industry =NULL
where industry ='';

select *
from Layoff_staging_2
where industry is null
or industry ='';

-- i couldnt find any other option than deleting the file . because there is no other option to populate the null value of industry.
delete 
from Layoff_staging_2
where industry is null
or industry ='';

select * 
from Layoff_staging_2
where company like 'Airb%';

select t1.industry , t2.industry
 from Layoff_staging_2 t1
 join Layoff_staging_2 t2
  on t1.company = t2.company
  where t1.industry is null
  and t2. industry is null;
  
-- Here, if we had atleast another column which represents laid off to calculate , we could have saved those data .
-- But unfortunately we need to delete 
  
delete
from Layoff_staging_2
where total_laid_off is Null
and percentage_laid_off is null;

select *
from Layoff_staging_2;

-- Now we can remove the row_num column

Alter table Layoff_staging_2
drop column row_numb;

-- Data Cleaning is done

-- Now we are going to do the EDA (Exploratory data analytics)

