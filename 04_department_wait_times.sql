-- ============================================================
-- Project: NHS Clinical Data Analysis
-- Script: 04_department_wait_times.sql
-- Objective: Calculate average and maximum length of stay (in days) per department
-- ============================================================

SELECT
	department, 
	COUNT(admission_id) as total_patients,
	ROUND(AVG(JULIANDAY(discharge_date)- JULIANDAY(admission_date)),1) as avg_stay_days,
	MAX(JULIANDAY(discharge_date)- JULIANDAY(admission_date)) as max_stay_days
FROM admissions 
WHERE discharge_date IS NOT NULL
GROUP BY department
ORDER BY avg_stay_days DESC;