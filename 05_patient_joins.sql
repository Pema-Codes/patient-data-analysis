-- Project: NHS Clinical Data Analysis
-- Script: 05_patient_joins.sql
-- Objective: Combine patient demographics with admission history using INNER and LEFT JOINs
-- ============================================================

-- Query 1: INNER JOIN - Returns only patients who have at least one admission record
SELECT
	p.patient_id,
	p.patient_name,
    p.age,
    p.gender,
    a.admission_id,
    a.department,
    a.admission_date,
    a.discharge_date,
    a.treatment_cost
FROM patients p
INNER JOIN admissions a 
	ON p.patient_id = a.patient_id 
ORDER BY a.admission_date ASC;


-- Query 2: LEFT JOIN - Returns ALL registered patients, even if they have no admissions (shows NULLs)
SELECT 
    p.patient_id,
    p.patient_name,
    p.age,
    a.admission_id,
    a.department,
    a.treatment_cost
FROM patients p
LEFT JOIN admissions a 
    ON p.patient_id = a.patient_id
ORDER BY p.patient_id ASC;