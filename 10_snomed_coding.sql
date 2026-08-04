-- ============================================================
-- Project: NHS Clinical Data Analysis
-- Script: 10_snomed_coding.sql
-- Objective: Create ICD-10/SNOMED CT lookup reference table and map clinical codes to admissions
-- ============================================================

-- Step 1: Create the Clinical Coding Reference Lookup Table
CREATE TABLE IF NOT EXISTS diagnosis_codes (
	code_id INTEGER PRIMARY KEY AUTOINCREMENT,
	department TEXT NOT NULL,
	icd10_code TEXT NOT NULL,
	snomedi_ct_code BIGINT NOT NULL,
	clinical_description TEXT NOT NULL 
);

-- Step 2: Populate Reference Table with Standardized Medical Codes
INSERT INTO diagnosis_codes (department, icd10_code, snomedi_ct_code, clinical_description) VALUES
('Cardiology', 'I21.9', 57054005, 'Acute Myocardial Infarction (Heart Attack)'),
('Oncology', 'C34.9', 254637007, 'Malignant Neoplasm of Unspecified Bronchus or Lung'),
('Emergency', 'R07.9', 29857009, 'Chest Pain, Unspecified');

-- Step 3: Query Admissions mapped against ICD-10 and SNOMED CT Clinical Codes
SELECT
	a.admission_id, 
	p.patient_id, 
	p.patient_name,
	a.department,
	d.icd10_code,
	d.snomedi_ct_code,
	d.clinical_description,
	a.admission_date, 
	a.treatment_cost
FROM admissions a 
INNER JOIN patients p 
	ON a.patient_id = p.patient_id 
LEFT JOIN diagnosis_codes d
	ON a.department = d.department 
ORDER BY a.admission_id ASC;
