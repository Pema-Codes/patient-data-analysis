-- ============================================================
-- Project: NHS Clinical Data Analysis
-- Script: 02_basic_filters.sql
-- Objective: Identify vulnerable elderly patients and high-cost specialist stays
-- ============================================================

-- ------------------------------------------------------------
-- Task 1: Identify Elderly Patients (Age >= 60)
-- Business Purpose: Early planning for social care support upon discharge.
-- ------------------------------------------------------------


SELECT patient_id, patient_name, age, gender
FROM patients
WHERE age >= 60
ORDER BY age DESC;

-- ------------------------------------------------------------
-- Task 2: High-Cost Inpatient Stays (> £1,000) in Specialist Wards
-- Business Purpose: Financial audit of Cardiology and Oncology spending.
-- ------------------------------------------------------------

SELECT 
    admission_id,
    patient_id,
    department,
    admission_date,
    treatment_cost
FROM admissions
WHERE treatment_cost > 1000.00
  AND department IN ('Cardiology', 'Oncology')
ORDER BY treatment_cost DESC;
