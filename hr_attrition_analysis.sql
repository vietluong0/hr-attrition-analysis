-- ============================================
-- HR Attrition Analysis
-- Author: Viet Luong
-- Date: April 16, 2026
-- Dataset: IBM HR Analytics (Kaggle)
-- Tool: PostgreSQL
-- ============================================

-- TABLE CREATION
CREATE TABLE hr_attrition (
    Age INT, Attrition VARCHAR(5), BusinessTravel VARCHAR(50),
    DailyRate INT, Department VARCHAR(50), DistanceFromHome INT,
    Education INT, EducationField VARCHAR(50), EmployeeCount INT,
    EmployeeNumber INT, EnvironmentSatisfaction INT, Gender VARCHAR(10),
    HourlyRate INT, JobInvolvement INT, JobLevel INT, JobRole VARCHAR(50),
    JobSatisfaction INT, MaritalStatus VARCHAR(20), MonthlyIncome INT,
    MonthlyRate INT, NumCompaniesWorked INT, Over18 VARCHAR(5),
    OverTime VARCHAR(5), PercentSalaryHike INT, PerformanceRating INT,
    RelationshipSatisfaction INT, StandardHours INT, StockOptionLevel INT,
    TotalWorkingYears INT, TrainingTimesLastYear INT, WorkLifeBalance INT,
    YearsAtCompany INT, YearsInCurrentRole INT, YearsSinceLastPromotion INT,
    YearsWithCurrManager INT
);

-- DATA IMPORT
COPY hr_attrition
FROM 'C:\Users\vietl\OneDrive\Desktop\Resume Project\WA_Fn-UseC_-HR-Employee-Attrition.csv'
DELIMITER ','
CSV HEADER;

-- ============================================
-- QUERY 1: Overall Attrition Rate
-- Finding: 16.12% overall attrition (above industry average of 10-15%)
-- ============================================
SELECT 
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM hr_attrition;

-- ============================================
-- QUERY 2: Attrition by Department
-- Finding: Sales (20.63%) and HR (19.05%) above average while R&D lowest (13.84%)
-- ============================================
SELECT 
    department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM hr_attrition
GROUP BY department
ORDER BY attrition_rate_pct DESC;

-- ============================================
-- QUERY 3: Attrition by Age Group
-- Finding: Under 25 group at 39.18% attrition, nearly 4x the rate of 35-44 group (10.10%)
-- ============================================
SELECT 
    CASE 
        WHEN age < 25 THEN 'Under 25'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM hr_attrition
GROUP BY age_group
ORDER BY attrition_rate_pct DESC;

-- ============================================
-- QUERY 4: Attrition by Income Band
-- Finding: Under $3K per month at 28.61% vs Over $10K at 8.90%; lower pay drives higher attrition
-- ============================================
SELECT 
    CASE 
        WHEN monthlyincome < 3000 THEN 'Under $3K'
        WHEN monthlyincome BETWEEN 3000 AND 5999 THEN '$3K-$6K'
        WHEN monthlyincome BETWEEN 6000 AND 9999 THEN '$6K-$10K'
        ELSE 'Over $10K'
    END AS income_band,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM hr_attrition
GROUP BY income_band
ORDER BY attrition_rate_pct DESC;

-- ============================================
-- QUERY 5: Attrition by Tenure
-- Finding: 0-1 year employees leave at 34.88% vs 10.38% for 10+ year employees
-- ============================================
SELECT 
    CASE
        WHEN yearsatcompany < 2 THEN '0-1 Years'
        WHEN yearsatcompany BETWEEN 2 AND 4 THEN '2-4 Years'
        WHEN yearsatcompany BETWEEN 5 AND 9 THEN '5-9 Years'
        ELSE '10+ Years'
    END AS tenure_band,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM hr_attrition
GROUP BY tenure_band
ORDER BY attrition_rate_pct DESC;

-- ============================================
-- QUERY 6: Attrition by Overtime
-- Finding: Overtime employees leave at 30.53% vs 10.44%, nearly 3x higher
-- ============================================
SELECT 
    overtime,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM hr_attrition
GROUP BY overtime
ORDER BY attrition_rate_pct DESC;

-- ============================================
-- QUERY 7: Attrition by Job Role
-- Finding: Sales Rep highest (39.76%), Research Director lowest (2.50%)
-- ============================================
SELECT 
    jobrole,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM hr_attrition
GROUP BY jobrole
ORDER BY attrition_rate_pct DESC;

-- ============================================
-- QUERY 8: High Risk Employee Profile 
-- Finding: Sales Rep + Overtime + 0-1 Years + Under $3K = 87.5% attrition rate
-- ============================================
SELECT 
    department,
    jobrole,
    overtime,
    CASE 
        WHEN yearsatcompany < 2 THEN '0-1 Years'
        WHEN yearsatcompany BETWEEN 2 AND 4 THEN '2-4 Years'
        WHEN yearsatcompany BETWEEN 5 AND 9 THEN '5-9 Years'
        ELSE '10+ Years'
    END AS tenure_band,
    CASE 
        WHEN monthlyincome < 3000 THEN 'Under $3K'
        WHEN monthlyincome BETWEEN 3000 AND 5999 THEN '$3K-$6K'
        WHEN monthlyincome BETWEEN 6000 AND 9999 THEN '$6K-$10K'
        ELSE 'Over $10K'
    END AS income_band,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM hr_attrition
GROUP BY department, jobrole, overtime, tenure_band, income_band
HAVING COUNT(*) >= 5
ORDER BY attrition_rate_pct DESC
LIMIT 10;