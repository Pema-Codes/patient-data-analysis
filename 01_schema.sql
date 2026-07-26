-- 1. Create Patients Table
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    patient_name TEXT,
    age INT,
    gender TEXT
);

-- 2. Create Admissions Table
CREATE TABLE admissions (
    admission_id INT PRIMARY KEY,
    patient_id INT,
    department TEXT,
    admission_date DATE,
    discharge_date DATE,
    treatment_cost DECIMAL(10,2),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

-- 3. Insert Patient Records
INSERT INTO patients VALUES
(101, 'Sarah Khan', 45, 'F'),
(102, 'John Smith', 62, 'M'),
(103, 'Elena Gomez', 29, 'F'),
(104, 'David Chen', 71, 'M'),
(105, 'Amira Patel', 53, 'F');

-- 4. Insert Admission Records
INSERT INTO admissions VALUES
(1, 101, 'Cardiology', '2026-01-10', '2026-01-14', 1200.00),
(2, 102, 'Oncology', '2026-01-12', '2026-01-20', 3500.00),
(3, 103, 'Cardiology', '2026-01-15', '2026-01-16', 450.00),
(4, 104, 'Emergency', '2026-01-18', '2026-01-19', 300.00),
(5, 105, 'Oncology', '2026-01-20', '2026-01-28', 2800.00),
(6, 101, 'Cardiology', '2026-02-01', '2026-02-05', 1100.00); -- Sarah Khan readmitted

