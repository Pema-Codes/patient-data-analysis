-- ============================================================
-- Project: NHS Clinical Data Analysis
-- Script: 11_monthly_trends.sql
-- Objective: Calculate monthly admission counts and cumulative running totals using SUM() OVER ()
-- ============================================================

--STEP 1: Groupinng by month(MonthlyAdmissions)
WITH MonthlyAdmissions AS (
	SELECT 
		strftime('%Y-%m', admission_date) AS admission_month,
		COUNT(admission_id) AS monthly_total_adms,
		ROUND(SUM(treatment_cost),2) AS monthly_expenditure
	FROM admissions
	GROUP BY strftime('%Y-%m', admission_date)
) 
-- STEP2: Calculate running totals
SELECT 
	admission_month, 
	monthly_total_adms,
	-- Running total of admissions over time
	SUM(monthly_total_adms) OVER (ORDER BY admission_month ASC) AS running_total_admissions,
	monthly_expenditure,
	--Running total of expenditure over time
	SUM(monthly_expenditure) OVER (ORDER BY admission_month ASC) AS running_total_expenditure
FROM MonthlyAdmissions
ORDER BY admission_month ASC;
	
	
