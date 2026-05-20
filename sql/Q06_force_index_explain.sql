USE hospital_db;

EXPLAIN
WITH hospitalization_review_avg AS (
    SELECT
        hospitalization_id,
        AVG(medical_care) AS avg_hospitalization_medical_care,
        AVG(nursing_care) AS avg_nursing_care,
        AVG(cleanliness) AS avg_cleanliness,
        AVG(food) AS avg_food,
        AVG(overall_experience) AS avg_overall_experience
    FROM hospitalization_review FORCE INDEX (idx_hospitalization_review_hosp)
    GROUP BY hospitalization_id
), doctor_review_avg AS (
    SELECT
        hospitalization_id,
        AVG(medical_care) AS avg_doctor_medical_care
    FROM doctor_review FORCE INDEX (idx_doctor_review_hosp)
    GROUP BY hospitalization_id
)
SELECT
    p.patient_id,
    p.first_name,
    p.last_name,
    h.hospitalization_id,
    d.name AS department_name,
    h.admission_date,
    h.discharge_date,
    h.admission_icd10_code,
    adm.description AS admission_diagnosis,
    h.discharge_icd10_code,
    dis.description AS discharge_diagnosis,
    h.ken_code,
    h.base_cost,
    h.extra_charge,
    h.total_cost,
    ROUND(hra.avg_hospitalization_medical_care, 2) AS avg_hospitalization_medical_care,
    ROUND(hra.avg_nursing_care, 2) AS avg_nursing_care,
    ROUND(hra.avg_cleanliness, 2) AS avg_cleanliness,
    ROUND(hra.avg_food, 2) AS avg_food,
    ROUND(hra.avg_overall_experience, 2) AS avg_overall_experience,
    ROUND(dra.avg_doctor_medical_care, 2) AS avg_doctor_medical_care
FROM patient p
JOIN hospitalization h FORCE INDEX (idx_hospitalization_patient)
    ON p.patient_id = h.patient_id
JOIN department d
    ON h.department_id = d.department_id
JOIN icd10_diagnosis adm
    ON h.admission_icd10_code = adm.icd10_code
LEFT JOIN icd10_diagnosis dis
    ON h.discharge_icd10_code = dis.icd10_code
LEFT JOIN hospitalization_review_avg hra
    ON h.hospitalization_id = hra.hospitalization_id
LEFT JOIN doctor_review_avg dra
    ON h.hospitalization_id = dra.hospitalization_id
WHERE p.patient_id = 1
ORDER BY h.admission_date;
