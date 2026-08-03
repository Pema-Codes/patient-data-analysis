-- ============================================================
-- Project: NHS Clinical Data Analysis
-- Script: 09_data_cleaning.sql
-- Objective: Clean missing discharge dates and standardize gender entries
-- ============================================================

-- Query 1: Standardize Gender values using CASE WHEN

SELECT 
	patient_id, 
	patient_name,
	age,
	gender AS raw_gender,
	CASE 
		WHEN UPPER(gender) IN ('M','Male') THEN 'Male'
		WHEN UPPER(gender) IN ('F', 'Female') THEN 'Female'
		ELSE 'Others/Unspecified'
	END AS standardized_gender
FROM patients;

-- Query 2: Handle NULL discharge dates for active patients
-- Replaces NULL discharge dates with 'Currently Admitted' or the current date for Length of Stay calculations
SELECT
	admission_id,
	patient_id,
	department,
	admission_date,
	discharge_date,
	-- Handle missing discharge date label
	CASE
		WHEN discharge_date IS NULL THEN 'Active Patient'
		ELSE discharge_date
	END AS discharge_status,
	-- Calculate length of stay (uses current date if discharge_date is NULL)
	ROUND(julianday(COALESCE(discharge_date, CURRENT_DATE))-julianday(admission_date), 1) AS current_los_days 
FROM admissions;
	
