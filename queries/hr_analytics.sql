-- Data Preparation and Validation


-- Create the table

CREATE TABLE hr_analytics (
    emp_id VARCHAR(10),
    age INT,
    age_group VARCHAR(20),
    attrition VARCHAR(5),
    business_travel VARCHAR(50),
    department VARCHAR(50),
    distance_from_home INT,
    education INT,
    education_field VARCHAR(50),
    employee_count INT,
    employee_number INT,
    gender VARCHAR(10),
    job_role VARCHAR(100),
    job_satisfaction INT,
    marital_status VARCHAR(20),
    monthly_income INT,
    salary_slab VARCHAR(20),
    over_time VARCHAR(5),
    percent_salary_hike INT,
    total_working_years INT,
    work_life_balance INT,
    years_at_company INT
);


-- View the imported data

SELECT 
	*
FROM hr_analytics
LIMIT 10;


-- Count the total records

SELECT 
	COUNT(*) AS total_records
FROM hr_analytics;


-- Check duplicate Employee IDs

SELECT
    emp_id,
    COUNT(*) AS duplicate_count
FROM hr_analytics
GROUP BY emp_id
	HAVING COUNT(*) > 1;


-- View the duplicate records

SELECT 
	*
FROM hr_analytics
WHERE emp_id = 'RM1467';


-- Delete all rows having duplicate emp_id

DELETE FROM hr_analytics
WHERE emp_id IN 
(
    SELECT emp_id
    FROM hr_analytics
    GROUP BY emp_id
    HAVING COUNT(*) > 1
);


-- Add Primary Key

-- Verify there are no duplicates

SELECT 
	emp_id, 
	COUNT(*)
FROM hr_analytics
GROUP BY emp_id
	HAVING COUNT(*) > 1;


-- Verify there are no NULL values

SELECT 
	*
FROM hr_analytics
WHERE emp_id IS NULL;


-- Add the Primary Key

ALTER TABLE hr_analytics
ADD CONSTRAINT hr_analytics_pkey
PRIMARY KEY (emp_id);


-- Verify the Primary Key

SELECT column_name
FROM information_schema.key_column_usage
WHERE table_name = 'hr_analytics';


-- Exploratory Data Analysis (EDA)


-- Q1. Which department has the highest average monthly income?

SELECT
    department,
    ROUND(AVG(monthly_income), 2) AS avg_monthly_income
FROM hr_analytics
GROUP BY department
ORDER BY avg_monthly_income DESC;


-- Q2. How many employees are working in each department?

SELECT
    department,
    COUNT(*) AS total_employees
FROM hr_analytics
GROUP BY department
ORDER BY total_employees DESC;


-- Q3. Display the Top 5 highest-paid employees.

SELECT
    emp_id,
    department,
    monthly_income
FROM hr_analytics
ORDER BY monthly_income DESC
LIMIT 5;


-- Q4. Which departments have more than 100 employees?

SELECT
    department,
    COUNT(*) AS total_employees
FROM hr_analytics
GROUP BY department
HAVING COUNT(*) > 100
ORDER BY total_employees DESC;


-- Q5. Find the number of employees who left the company in each department.

SELECT
    department,
    COUNT(*) AS attrition_count
FROM hr_analytics
WHERE attrition = 'Yes'
GROUP BY department
ORDER BY attrition_count DESC;


-- Business Analysis


-- Q6. Find employees whose monthly income is 
-- greater than the company's average salary.

SELECT
    emp_id,
    department,
    monthly_income
FROM hr_analytics
WHERE monthly_income >
(
    SELECT AVG(monthly_income)
    FROM hr_analytics
)
ORDER BY monthly_income DESC;


-- Q7. Rank employees based on monthly income within each department.

SELECT
    emp_id,
    department,
    monthly_income,
    RANK() OVER
	(
		PARTITION BY department
		ORDER BY monthly_income DESC
	) AS salary_rank
FROM hr_analytics;


-- Q8. Find the highest-paid employee from each department.

WITH highest_salary AS
(
    SELECT
        emp_id,
        department,
        monthly_income,
        ROW_NUMBER() OVER
        (
            PARTITION BY department
            ORDER BY monthly_income DESC
        ) AS rn
    FROM hr_analytics
)

SELECT
    emp_id,
    department,
    monthly_income
FROM highest_salary
WHERE rn = 1;


-- Q9. Which education field has the highest attrition count?

SELECT
    education_field,
    COUNT(*) AS attrition_count
FROM hr_analytics
WHERE attrition = 'Yes'
GROUP BY education_field
ORDER BY attrition_count DESC;


-- Q10. Create a department-wise HR summary report.

SELECT
    department,
    COUNT(*) AS total_employees,
    ROUND(AVG(monthly_income),2) AS avg_salary,
    ROUND(AVG(total_working_years),2) AS avg_experience,
    SUM
		( 
		CASE 
			WHEN attrition='Yes' THEN 1 ELSE 0 
		END 
		) AS attrition_count,
    ROUND(AVG(job_satisfaction),2) AS avg_job_satisfaction
FROM hr_analytics
GROUP BY department
ORDER BY total_employees DESC;