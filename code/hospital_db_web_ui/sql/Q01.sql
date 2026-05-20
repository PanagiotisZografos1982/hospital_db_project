SELECT
    d.department_id,
    d.name AS department_name,
    YEAR(h.admission_date) AS admission_year,
    h.ken_code,
    k.description AS ken_description,
    ip.insurance_provider_id,
    ip.name AS insurance_provider_name,
    COUNT(*) AS hospitalization_count,
    ROUND(SUM(h.base_cost), 2) AS total_base_cost,
    ROUND(SUM(h.extra_charge), 2) AS total_extra_charge_due_to_los_excess,
    ROUND(SUM(h.total_cost), 2) AS total_revenue
FROM hospitalization h
JOIN department d
    ON h.department_id = d.department_id
JOIN ken_code k
    ON h.ken_code = k.ken_code
JOIN patient p
    ON h.patient_id = p.patient_id
JOIN insurance_provider ip
    ON p.insurance_provider_id = ip.insurance_provider_id
GROUP BY
    d.department_id,
    d.name,
    YEAR(h.admission_date),
    h.ken_code,
    k.description,
    ip.insurance_provider_id,
    ip.name
ORDER BY
    admission_year,
    d.department_id,
    h.ken_code,
    ip.insurance_provider_id;
