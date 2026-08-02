-- ============================================================
-- Project: NHS Clinical Data Analysis
-- Script: 07_cohort_ctes.sql
-- Objective: Segment high-risk elderly patients with high total expenditure using modular CTEs
-- ============================================================

-- Step 1: Calculate total spending per patient
WITH PatientSpending AS (
	SELECT 
		patient_id,
		COUNT(admission_id) AS total_admissions,
		ROUND(SUM(treatment_cost),2) AS total_spent
	FROM admissions
	GROUP BY patient_id
),

-- Step 2: Filter for elderly/vulnerable demographic (Age >= 60)
VulnerablePatients AS (
	SELECT
		 patient_id,
		 patient_name,
		 age,
		 gender
	FROM patients 
	WHERE age >= 60
)

-- Step 3: Combine both CTEs to output high-risk cohort (Spent > £1000 AND Age >= 60)
SELECT 
	vp.patient_id,
	vp.patient_name,
	vp.age, 
	vp.gender,
	ps.total_admissions, 
	ps.total_spent
FROM VulnerablePatients vp
INNER JOIN PatientSpending ps
	ON vp.patient_id = ps.patient_id
WHERE ps.total_spent > 1000.00
ORDER BY ps.total_spent DESC;