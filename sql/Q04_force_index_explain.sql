USE hospital_db;

SET @target_doctor_id := 11;

EXPLAIN
WITH doctor_review_avg AS (
    SELECT
        dr.doctor_id,
        COUNT(DISTINCT dr.doctor_review_id) AS review_count,
        ROUND(AVG(dr.medical_care), 2) AS avg_doctor_medical_care
    FROM doctor_review dr FORCE INDEX (idx_doctor_review_doctor)
    WHERE dr.doctor_id = @target_doctor_id
    GROUP BY dr.doctor_id
),
hospitalization_review_avg AS (
    SELECT
        dr.doctor_id,
        ROUND(AVG(hr.medical_care), 2) AS avg_hospitalization_medical_care,
        ROUND(AVG(hr.overall_experience), 2) AS avg_overall_hospitalization_experience,
        ROUND(AVG(hr.nursing_care), 2) AS avg_nursing_care,
        ROUND(AVG(hr.cleanliness), 2) AS avg_cleanliness,
        ROUND(AVG(hr.food), 2) AS avg_food
    FROM doctor_review dr FORCE INDEX (idx_doctor_review_doctor)
    JOIN hospitalization h
        ON dr.hospitalization_id = h.hospitalization_id
    LEFT JOIN hospitalization_review hr FORCE INDEX (idx_hospitalization_review_hosp)
        ON h.hospitalization_id = hr.hospitalization_id
    WHERE dr.doctor_id = @target_doctor_id
    GROUP BY dr.doctor_id
)
SELECT
    d.staff_id AS doctor_id,
    s.first_name,
    s.last_name,
    d.specialty,
    d.doctor_rank,
    COALESCE(dra.review_count, 0) AS review_count,
    dra.avg_doctor_medical_care,
    hra.avg_hospitalization_medical_care,
    hra.avg_overall_hospitalization_experience,
    hra.avg_nursing_care,
    hra.avg_cleanliness,
    hra.avg_food
FROM doctor d
JOIN staff s
    ON d.staff_id = s.staff_id
LEFT JOIN doctor_review_avg dra
    ON d.staff_id = dra.doctor_id
LEFT JOIN hospitalization_review_avg hra
    ON d.staff_id = hra.doctor_id
WHERE d.staff_id = @target_doctor_id;