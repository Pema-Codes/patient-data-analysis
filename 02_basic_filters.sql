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