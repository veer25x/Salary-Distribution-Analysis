
USE salary_analysis;
CREATE TABLE salary_data (
    age DECIMAL,
    gender VARCHAR(20),
    education_level VARCHAR(50),
    job_title VARCHAR(150),
    years_of_experience DECIMAL,
    salary DECIMAL
);

salary_data_cleaned.csv

SELECT COUNT(*) AS total_employees
FROM salary_data;

SELECT 
    ROUND(AVG(salary), 2) AS average_salary
FROM salary_data;

SELECT 
    PERCENTILE_CONT(0.5) 
    WITHIN GROUP (ORDER BY salary) AS median_salary
FROM salary_data;

SELECT
    MIN(salary) AS minimum_salary,
    MAX(salary) AS maximum_salary
FROM salary_data;


SELECT
    gender,
    COUNT(*) AS employees,
    ROUND(AVG(salary), 2) AS average_salary,
    PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY salary) AS median_salary
FROM salary_data
GROUP BY gender
ORDER BY average_salary DESC;


SELECT
    education_level,
    COUNT(*) AS employees,
    ROUND(AVG(salary), 2) AS average_salary,
    PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY salary) AS median_salary
FROM salary_data
GROUP BY education_level
ORDER BY average_salary DESC;

SELECT
    CASE
        WHEN years_of_experience < 3 THEN '0-2 Years'
        WHEN years_of_experience < 6 THEN '3-5 Years'
        WHEN years_of_experience < 11 THEN '6-10 Years'
        WHEN years_of_experience < 16 THEN '11-15 Years'
        ELSE '16+ Years'
    END AS experience_group,

    COUNT(*) AS employees,
    ROUND(AVG(salary), 2) AS average_salary

FROM salary_data

GROUP BY experience_group

ORDER BY average_salary;

SELECT
    job_title,
    COUNT(*) AS employees,
    ROUND(AVG(salary), 2) AS average_salary
FROM salary_data
GROUP BY job_title
HAVING COUNT(*) >= 2
ORDER BY average_salary DESC
LIMIT 15;


SELECT
    job_title,
    education_level,
    years_of_experience,
    salary
FROM salary_data
ORDER BY salary DESC
LIMIT 10;


SELECT
    CASE
        WHEN salary < 50000 THEN 'Below 50K'
        WHEN salary < 100000 THEN '50K-100K'
        WHEN salary < 150000 THEN '100K-150K'
        WHEN salary < 200000 THEN '150K-200K'
        ELSE '200K+'
    END AS salary_band,

    COUNT(*) AS employees

FROM salary_data

GROUP BY salary_band

ORDER BY MIN(salary);

SELECT
    job_title,
    COUNT(*) AS employees,
    ROUND(AVG(salary), 2) AS average_salary,

    RANK() OVER (
        ORDER BY AVG(salary) DESC
    ) AS salary_rank

FROM salary_data

GROUP BY job_title
HAVING COUNT(*) >= 2;
WITH job_salary AS (

    SELECT
        job_title,
        COUNT(*) AS employees,
        AVG(salary) AS average_salary
    FROM salary_data
    GROUP BY job_title

)

SELECT *
FROM job_salary
WHERE employees >= 2
ORDER BY average_salary DESC;
