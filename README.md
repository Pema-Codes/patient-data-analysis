# NHS Clinical Data Analysis & Audit

## Executive Summary
This project analyzes inpatient admission records to identify vulnerable elderly patient cohorts, evaluate length of stay (LOS) operational bottlenecks, and perform financial auditing on high-cost specialist ward stays (Cardiology, Oncology, Emergency).

The goal is to provide data-driven operational insights for NHS trust management to optimize bed capacity, streamline community discharge planning, and control departmental expenditure. 

---

## Tech Stack & Database Schema
* **Database Engine:** SQLite / PostgreSQL
* **SQL Interface:** DBeaver Community Edition
* **Key Concepts:** Data Filtering (`WHERE`), Aggregations (`GROUP BY`, `SUM()`, `AVERAGE()`, `COUNT()`), Date Calculations (`JULIANDAY`), Sorting (`ORDER BY`), Rounding(`ROUND()`)

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
***Output:***

|patient_id|patient_name|age|gender|
|----------|------------|---|------|
|104|David Chen|71|M|
|102|John Smith|62|M|

### 2. High-Cost Specialist Admissions (> £1,000)
**Business Objective:** Financial oversight of high-expenditure inpatient stays in Cardiology and Oncology wards.

**SQL Code (`02_basic_filters.sql`):** 
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
***Output:***

|admission_id|patient_id|department|admission_date|treatment_cost|
|------------|----------|----------|--------------|--------------|
|2|102|Oncology|2026-01-12|3500|
|5|105|Oncology|2026-01-20|2800|
|1|101|Cardiology|2026-01-10|1200|
|6|101|Cardiology|2026-02-01|1100|

### 3. Departmental Financial Audit (Volume & Cost)

Business Objective: Evaluate total expenditure and average cost per stay across specialties to inform annual trust budget allocation.

***SQL Code (`03_department_costs.sql`):***
```sql
SELECT 
    department,
    COUNT(admission_id) AS total_admissions,
    ROUND(SUM(treatment_cost), 2) AS total_department_cost,
    ROUND(AVG(treatment_cost), 2) AS avg_cost_per_admission
FROM admissions
GROUP BY department
ORDER BY total_department_cost DESC;
```
***Output:***

|department|total_admissions|total_department_cost|avg_cost_per_admission|
|----------|----------------|---------------------|----------------------|
|Oncology|2|6300.0|3150.0|
|Cardiology|3|2750.0|916.67|
|Emergency|1|300.0|300.0|

### 4. Length of Stay & Operational Bottlenecks

Business Objective: Measure average bed occupancy days per department to identify discharge delays and bed availability bottlenecks.

***SQL Code (`04_department_wait_times.sql`):***
```sql
SELECT 
    department,
    COUNT(admission_id) AS total_patients,
    ROUND(AVG(JULIANDAY(discharge_date) - JULIANDAY(admission_date)), 1) AS avg_stay_days,
    MAX(JULIANDAY(discharge_date) - JULIANDAY(admission_date)) AS max_stay_days
FROM admissions
WHERE discharge_date IS NOT NULL
GROUP BY department
ORDER BY avg_stay_days DESC;
```
***Output:***

|department|total_patients|avg_stay_days|max_stay_days|
|----------|--------------|-------------|-------------|
|Oncology|2|8.0|8.0|
|Cardiology|3|3.0|4.0|
|Emergency|1|1.0|1.0|

## Key Findings & Recommendations
***High Oncology Resource Intensity:*** Oncology accounts for the largest share of overall expenditures (£6,300.00) and the longest length of stay (8.0 days average).

Recommendation: Conduct a secondary clinical audit into the primary drivers of inpatient Oncology stays (such as pre-chemotherapy workups vs. active treatment monitoring) to evaluate if stable pre-treatment assessments can be safely transitioned to outpatient day clinics to free up inpatient bed capacity. 

***Readmission Risk Signaling:*** Patient 101 (Sarah Khan) had two separate Cardiology admissions within 3 weeks (18 days apart). This indicates a potential gap in post-discharge support. 

Recommendation: Establish a mandatory 7-day post-discharge phone check-in protocol for all Cardiology patients to audit medication adherence, address early symptom flare-ups, and reduce avoidable 30-day readmissions.

***Emergency Efficiency:*** Emergency admissions demonstrate rapid throughput (1.0 days average stay), meeting acute operational discharge targets. 
