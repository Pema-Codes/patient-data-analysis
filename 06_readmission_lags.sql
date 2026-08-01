-- ============================================================
-- Project: NHS Clinical Data Analysis
-- Script: 06_readmission_lags.sql
-- Objective: Calculate days between previous discharge and next admission using LAG()
-- ============================================================

WITH PatientStays AS (
	SELECT
		patient_id,
		admission_id,
		department,
		admission_date,
		discharge_date,
		-- Get the discharge date from the patient's previous visit
		LAG(discharge_date,1) OVER (
			PARTITION BY patient_id
			ORDER BY admission_date ASC
			) AS prev_discharge_date
	FROM admissions
)

SELECT 
	patient_id,
	admission_id,
	department,
	admission_id,
	prev_discharge_date,
	-- Calculate days between previous discharge and current admission
	ROUND(JULIANDAY(admission_date) - julianday(prev_discharge_date), 0) AS days_since_last_discharge,
	-- Flag readmissoins that occur within 30 days
	CASE
		WHEN (julianday(admission_date)- julianday(prev_discharge_date)) <=30 THEN 1
		ELSE 0
	END AS is_30day_readmission
FROM PatientStays
ORDER BY patient_id ASC, admission_date ASC;	