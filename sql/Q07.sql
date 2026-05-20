SELECT
    a.substance_id,
    a.name AS substance_name,
    COUNT(DISTINCT pa.patient_id) AS allergic_patient_count,
    COUNT(DISTINCT ms.medication_id) AS medication_count
FROM active_substance a
LEFT JOIN patient_allergy pa
    ON a.substance_id = pa.substance_id
LEFT JOIN medication_substance ms
    ON a.substance_id = ms.substance_id
GROUP BY
    a.substance_id,
    a.name
ORDER BY
    allergic_patient_count DESC,
    medication_count DESC,
    a.substance_id ASC;
