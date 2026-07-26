# NHS Clinical Data Analysis & Audit

## Executive Summary
This project analyzes inpatient admission records to identify vulnerable elderly patient cohorts and perform financial auditing on high-cost specialist ward stays (Cardiology & Oncology). 

The goal is to provide operational insights for NHS trust management to optimize resource allocation and discharge planning.

---

## Tech Stack & Database Schema
* **Database Engine:** SQLite / PostgreSQL
* **SQL Interface:** DBeaver Community Edition
* **Key Concepts:** Data Filtering (`WHERE`), Aggregations (`GROUP BY`), Sorting (`ORDER BY`)

---

## Key Business Questions & SQL Solutions

### 1. Identifying Vulnerable Elderly Patients (Age >= 60)
**Business Objective:** Early identification of senior patients to coordinate community care and reduce delayed discharges.

**SQL Code (`02_basic_filters.sql`):**
```sql
SELECT 
    patient_id,
    patient_name,
    age,
    gender
FROM patients
WHERE age >= 60
ORDER BY age DESC;
```
|patient_id|patient_name|age|gender|
|----------|------------|---|------|
|104|David Chen|71|M|
|102|John Smith|62|M|

### 2. High-Cost Specialist Admissions (> £1,000)
**Business Objective:** Financial oversight of high-expenditure inpatient stays in Cardiology and Oncology wards.

**SQL Code (02_basic_filters.sql):** 
```sql
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
```
|admission_id|patient_id|department|admission_date|treatment_cost|
|------------|----------|----------|--------------|--------------|
|2|102|Oncology|2026-01-12|3500|
|5|105|Oncology|2026-01-20|2800|
|1|101|Cardiology|2026-01-10|1200|
|6|101|Cardiology|2026-02-01|1100|

## Key Findings & Recommendations
Oncology Expenditures: Oncology admissions represent the highest single-stay treatment costs (> £2,800), warranting further audit into medication costs.

Readmission Risk: Patient 101 (Sarah Khan) had two separate Cardiology admissions within 3 weeks, signaling potential post-discharge follow-up improvements needed.
