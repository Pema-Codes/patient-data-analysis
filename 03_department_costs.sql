-- ============================================================
-- Project: NHS Clinical Data Analysis
-- Script: 03_department_costs.sql
-- Objective: Aggregate total expenditure, average costs, and volume by department
-- ============================================================

SELECT 
	department,
	COUNT(admission_id) as total_admissions,
	ROUND(SUM(treatment_cost),2) as total_department_cost ,
	ROUND(AVG(treatment_cost),2) as avg_cost_per_admission
FROM admissions 
GROUP BY department
ORDER BY total_department_cost DESC ; 




