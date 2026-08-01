-- ============================================================
-- Project: NHS Clinical Data Analysis
-- Script: 07_high_cost_ranking.sql
-- Objective: Rank treatment costs within each department using RANK() OVER()
-- ============================================================

WITH RankedAdmissions AS (
	SELECT 
		a.admission_id, 
		p.patient_id, 
		p.patient_name,
		a.department,
		a.treatment_cost,
		-- Rank admissions by cost within each department 
		RANK() OVER (
			PARTITION BY a.department
			ORDER BY a.treatment_cost DESC
			) AS Cost_rank 
FROM admissions a INNER JOIN patients p 
ON a.patient_id = p.patient_id 
)

SELECT
	department,
	cost_rank,
	admission_id,
	patient_id,
	patient_name,
	treatment_cost
FROM RankedAdmissions 
WHERE cost_rank <= 3
ORDER BY department ASC, Cost_rank ASC;
