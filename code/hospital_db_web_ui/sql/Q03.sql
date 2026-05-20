SELECT
    p.patient_id,
    p.amka,
    p.first_name,
    p.last_name,
    d.department_id,
    d.name AS department_name,
    COUNT(h.hospitalization_id) AS hospitalization_count_same_department,
    ROUND(SUM(h.total_cost), 2) AS total_hospitalization_cost
FROM patient p
JOIN hospitalization h
    ON p.patient_id = h.patient_id
JOIN department d
    ON h.department_id = d.department_id
GROUP BY
    p.patient_id,
    p.amka,
    p.first_name,
    p.last_name,
    d.department_id,
    d.name
HAVING COUNT(h.hospitalization_id) > 3
ORDER BY
    hospitalization_count_same_department DESC,
    total_hospitalization_cost DESC,
    p.patient_id,
    d.department_id;
