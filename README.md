# NHS Clinical Data Analysis & Audit

## Executive Summary
This project analyzes inpatient admission records to identify vulnerable elderly patient cohorts, evaluate length of stay (LOS) operational bottlenecks, and perform relational data joins across clinical tables, track 30-day readmissions, rank high-cost treatment stays and segment high-risk patient cohorts using modular Common Table Expressions (CTEs) using advanced window functions, perform data cleaning/standardization for active admissions and inconsistent patient registries, implement international clinical terminology mapping (ICD-10 / SNOMED CT), conduct financial auditing on high-cost specialist ward stays (Cardiology, Oncology, Emergency) and evaluate cumulative monthly patient throughput and budget expenditure using window function running totals. 

The goal is to provide data-driven operational insights for NHS trust management to optimize bed capacity, streamline community discharge planning, data quality governance, clinical interoperability and departmental budget allocation. 

---

## Tech Stack & Database Schema
* **Database Engine:** SQLite / PostgreSQL
* **SQL Interface:** DBeaver Community Edition
* **Key Concepts:** Cumulative Running Totals (`SUM() OVER`), Date Formatting (`strftime`), Clinical Terminology Mapping (ICD-10, SNOMED CT), Data Cleaning (`COALESCE`, `UPPER`, `IS NULL`)Window Functions (`RANK()`,`LAG()`, `OVER`, `PARTITION BY`), Relational Joins (`INNER JOIN`, `LEFT JOIN`), Common Table Expressions (`WITH ...AS`), Data Filtering (`WHERE`), Aggregations (`GROUP BY`, `SUM()`, `AVERAGE()`, `COUNT()`), Date Calculations (`JULIANDAY`), Conditional Logic(`CASE WHEN`), Sorting (`ORDER BY`), Rounding(`ROUND()`)

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
**Output:**

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
**Output:**

|admission_id|patient_id|department|admission_date|treatment_cost|
|------------|----------|----------|--------------|--------------|
|2|102|Oncology|2026-01-12|3500|
|5|105|Oncology|2026-01-20|2800|
|1|101|Cardiology|2026-01-10|1200|
|6|101|Cardiology|2026-02-01|1100|

### 3. Departmental Financial Audit (Volume & Cost)

**Business Objective:** Evaluate total expenditure and average cost per stay across specialties to inform annual trust budget allocation.

**SQL Code (`03_department_costs.sql`):**
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
**Output:**

|department|total_admissions|total_department_cost|avg_cost_per_admission|
|----------|----------------|---------------------|----------------------|
|Oncology|2|6300.0|3150.0|
|Cardiology|3|2750.0|916.67|
|Emergency|1|300.0|300.0|

### 4. Length of Stay & Operational Bottlenecks

**Business Objective:** Measure average bed occupancy days per department to identify discharge delays and bed availability bottlenecks.

**SQL Code (`04_department_wait_times.sql`):**
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
**Output:**

|department|total_patients|avg_stay_days|max_stay_days|
|----------|--------------|-------------|-------------|
|Oncology|2|8.0|8.0|
|Cardiology|3|3.0|4.0|
|Emergency|1|1.0|1.0|

### 5. Patient Demographic & Admission Joins
**Business Objective:** Link demographic patient profiles with active clinical admission histories and audit total patient registry records.

**SQL Code (`05_patient_joins.sql`):**
```sql
-- Query 1: Active Admissions (INNER JOIN)
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

-- Query 2: Full Registry Audit (LEFT JOIN)
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
```
**Output (INNER JOIN)- Active Admissions**

|patient_id|patient_name|age|gender|admission_id|department|admission_date|discharge_date|treatment_cost|
|----------|------------|---|------|------------|----------|--------------|--------------|--------------|
|101|Sarah Khan|45|F|1|Cardiology|2026-01-10|2026-01-14|1200|
|102|John Smith|62|M|2|Oncology|2026-01-12|2026-01-20|3500|
|103|Elena Gomez|29|F|3|Cardiology|2026-01-15|2026-01-16|450|
|104|David Chen|71|M|4|Emergency|2026-01-18|2026-01-19|300|
|105|Amira Patel|53|F|5|Oncology|2026-01-20|2026-01-28|2800|
|101|Sarah Khan|45|F|6|Cardiology|2026-02-01|2026-02-05|1100|

**Output (INNER JOIN)- Full Registry Audit**

|patient_id|patient_name|age|admission_id|department|treatment_cost|
|----------|------------|---|------------|----------|--------------|
|101|Sarah Khan|45|1|Cardiology|1200|
|101|Sarah Khan|45|6|Cardiology|1100|
|102|John Smith|62|2|Oncology|3500|
|103|Elena Gomez|29|3|Cardiology|450|
|104|David Chen|71|4|Emergency|300|
|105|Amira Patel|53|5|Oncology|2800|

### 6. Unplanned 30-day Readmission Analysis

**Business Objective**: Automatically track patient return gaps using the LAG() window function to identify high-risk readmission events that signal care quality issues. 

**SQL Code (`06_readmission_lags.sql`):**
```sql
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
```
**Output:**
|patient_id|admission_id|department|admission_id|prev_discharge_date|days_since_last_discharge|is_30day_readmission|
|----------|------------|----------|------------|-------------------|-------------------------|--------------------|
|101|1|Cardiology|1|||0|
|101|6|Cardiology|6|2026-01-14|18.0|1|
|102|2|Oncology|2|||0|
|103|3|Cardiology|3|||0|
|104|4|Emergency|4|||0|
|105|5|Oncology|5|||0|

### 7. Departmental Cost Ranking (Top 3 Cases per Specialty) 

**Business Objective**: Rank treatment costs within each department independently using RANK() OVER (PARTITION BY ...) to spotlight extreme financial outliers for clinical auditing.

**SQL Code (`07_high_cost_ranking.sql`)**:
```sql
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
```
**Output**:

|department|Cost_rank|admission_id|patient_id|patient_name|treatment_cost|
|----------|---------|------------|----------|------------|--------------|
|Cardiology|1|1|101|Sarah Khan|1200|
|Cardiology|2|6|101|Sarah Khan|1100|
|Cardiology|3|3|103|Elena Gomez|450|
|Emergency|1|4|104|David Chen|300|
|Oncology|1|2|102|John Smith|3500|
|Oncology|2|5|105|Amira Patel|2800|

### 8. High-Risk Cohort Segmentation via Modular CTEs

**Business Objective:** Segment high-risk, high-cost vulnerable patients (Age >= 60 AND Total Spent > £1,000) using multi-stage Common Table Expressions to target multi-disciplinary care interventions.

**SQL Code (`08_cohort_ctes.sql`):**

```sql
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
```
**Output:** 
|patient_id|patient_name|age|gender|total_admissions|total_spent|
|----------|------------|---|------|----------------|-----------|
|102|John Smith|62|M|1|3500.0|

### 9. Data Cleaning & Standardization (Active Stays & Gender Formats)

**Business Objective:** Handle un-discharged active stays (NULL values) and standardize mixed registration text formats ('M', 'Male', 'F', 'Female') to preserve data integrity for trust-wide reporting.

**SQL Code (`09_data_cleaning.sql`):**

```sql
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
```	
**Output (Gender values standardized):**
|patient_id|patient_name|age|raw_gender|standardized_gender|
|----------|------------|---|----------|-------------------|
|101|Sarah Khan|45|F|Female|
|102|John Smith|62|M|Male|
|103|Elena Gomez|29|F|Female|
|104|David Chen|71|M|Male|
|105|Amira Patel|53|F|Female|

**Output (Active Stays Cleaned):**
|admission_id|patient_id|department|admission_date|discharge_date|discharge_status|current_los_days|
|------------|----------|----------|--------------|--------------|----------------|----------------|
|1|101|Cardiology|2026-01-10|2026-01-14|2026-01-14|4.0|
|2|102|Oncology|2026-01-12|2026-01-20|2026-01-20|8.0|
|3|103|Cardiology|2026-01-15|2026-01-16|2026-01-16|1.0|
|4|104|Emergency|2026-01-18|2026-01-19|2026-01-19|1.0|
|5|105|Oncology|2026-01-20|2026-01-28|2026-01-28|8.0|
|6|101|Cardiology|2026-02-01|2026-02-05|2026-02-05|4.0|

### 10. Clinical Terminology Mapping (ICD-10 & SNOMED CT)

**Business Objective:** Build a relational clinical lookup reference table (diagnosis_codes) to map raw department visits to global standard ICD-10 disease codes and SNOMED CT terminology concepts for research and clinical coding alignment.

**SQL Code (`10_snomed_coding.sql`):**
```sql
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
```

**Output:**
|admission_id|patient_id|patient_name|department|icd10_code|snomedi_ct_code|clinical_description|admission_date|treatment_cost|
|------------|----------|------------|----------|----------|---------------|--------------------|--------------|--------------|
|1|101|Sarah Khan|Cardiology|I21.9|57054005|Acute Myocardial Infarction (Heart Attack)|2026-01-10|1200|
|2|102|John Smith|Oncology|C34.9|254637007|Malignant Neoplasm of Unspecified Bronchus or Lung|2026-01-12|3500|
|3|103|Elena Gomez|Cardiology|I21.9|57054005|Acute Myocardial Infarction (Heart Attack)|2026-01-15|450|
|4|104|David Chen|Emergency|R07.9|29857009|Chest Pain, Unspecified|2026-01-18|300|
|5|105|Amira Patel|Oncology|C34.9|254637007|Malignant Neoplasm of Unspecified Bronchus or Lung|2026-01-20|2800|
|6|101|Sarah Khan|Cardiology|I21.9|57054005|Acute Myocardial Infarction (Heart Attack)|2026-02-01|1100|

### 11. Cumulative Monthly Trends & Budget Analysis

**Business Objective:** Track cumulative monthly admission growth and running expenditure totals using SUM() OVER (ORDER BY ...) to provide senior management with long-term volume and budget tracking.

**SQL Code (`11_monthly_trends.sql`):**
```sql
--STEP 1: Groupinng by month(MonthlyAdmissions)
WITH MonthlyAdmissions AS (
	SELECT 
		strftime('%Y-%m', admission_date) AS admission_month,
		COUNT(admission_id) AS monthly_total_adms,
		ROUND(SUM(treatment_cost),2) AS monthly_expenditure
	FROM admissions
	GROUP BY strftime('%Y-%m', admission_date)
) 
-- STEP2: Calculate running totals
SELECT 
	admission_month, 
	monthly_total_adms,
	-- Running total of admissions over time
	SUM(monthly_total_adms) OVER (ORDER BY admission_month ASC) AS running_total_admissions,
	monthly_expenditure,
	--Running total of expenditure over time
	SUM(monthly_expenditure) OVER (ORDER BY admission_month ASC) AS running_total_expenditure
FROM MonthlyAdmissions
ORDER BY admission_month ASC;
```
**Output:**
|admission_month|monthly_total_adms|running_total_admissions|monthly_expenditure|running_total_expenditure|
|---------------|------------------|------------------------|-------------------|-------------------------|
|2026-01|5|5|8250.0|8250.0|
|2026-02|1|6|1100.0|9350.0|

## Key Findings & Recommendations

**1. Cumulative Financial & Operational Forecasting:** Running totals reveal that trust expenditure reached £9,350.0 across 6 total admissions by February 2026, with the vast majority (£8250.00) consumed in January. **Recommendation:** Establish dynamic monthly budget burn-rate alerts to detect front-loaded operational expenditure early in the financial year.

**2. Clinical Coding & Interoperability Standardization:** Mapping department encounters to standardized ICD-10 and SNOMED CT codes resolves medical ambiguity and ensures compliance with NHS digital health records standards. **Recommendation:** Mandatory integration of SNOMED CT clinical coding lookup tables across electronic health records (EHR) to streamline clinical reporting and epidemiological audit trails.

**3. Data Standardization & Governance:** Inconsistent entry formats (`'M'` vs `'Male'`) and un-discharged `NULL` records introduce reporting errors in aggregation queries. **Recommendation:** Implement automated data validation rules at reception check-in and utilize `COALESCE`(discharge_date, CURRENT_DATE) in operational dashboards to track active bed occupancy in real time.

**4. High Oncology Resource Intensity:** Oncology accounts for the largest share of overall expenditures (£6,300.00) and the longest length of stay ***(8.0 days average)***. 
**Recommendation:** Conduct a secondary clinical audit into the primary drivers of inpatient Oncology stays (such as pre-chemotherapy workups vs. active treatment monitoring) to evaluate if stable pre-treatment assessments can be safely transitioned to outpatient day clinics to free up inpatient bed capacity. 

**5. Readmission Risk Signaling:** Patient `101` (Sarah Khan) had two separate Cardiology admissions within 3 weeks (18 days apart). This indicates a potential gap in post-discharge support. 
**Recommendation:** Establish a mandatory ***7-day post-discharge phone check-in protocol*** for all Cardiology patients to audit medication adherence, address early symptom flare-ups, and reduce avoidable 30-day readmissions.

**6. High-Risk Vulnerable Cohort Management:** The CTE cohort segmentation identified senior high-cost individuals such as John Smith (Age 62, £3,500.00 total expenditure). 
***Recommendation:*** Assign dedicated Multi-Disciplinary Team (MDT) caseworkers and social care coordinators to senior patients meeting the high-cost threshold to structure comprehensive post-discharge plans.

**7. Departmental Outlier Identification:** The RANK() audit revealed John Smith (£3,500.00) and Chloe Adams (£2,800.00) as the top two financial expenditures in Oncology. 
***Recommendation:*** Implement senior financial case reviews for top-tier ranked cases to audit pharmaceutical expenditure against standardized treatment pathways.

**8. Emergency Efficiency:** Emergency admissions demonstrate rapid throughput (***1.0 days average stay***), meeting acute operational discharge targets. 
