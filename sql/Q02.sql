SELECT
    d.staff_id AS doctor_id,
    s.first_name,
    s.last_name,
    d.specialty,
    d.doctor_rank,
    CASE
        WHEN COUNT(DISTINCT sh.shift_id) > 0 THEN 'YES'
        ELSE 'NO'
    END AS had_shift_current_year,
    COUNT(DISTINCT sh.shift_id) AS shift_count_current_year,
    COUNT(DISTINCT pp.performed_id) AS main_surgeon_procedure_count
FROM doctor d
JOIN staff s
    ON d.staff_id = s.staff_id
LEFT JOIN shift_assignment sa
    ON d.staff_id = sa.staff_id
LEFT JOIN shift sh
    ON sa.shift_id = sh.shift_id
    AND YEAR(sh.shift_date) = YEAR(CURDATE())
LEFT JOIN performed_procedure pp
    ON d.staff_id = pp.main_surgeon_id
WHERE d.specialty = 'Χειρουργική'
GROUP BY
    d.staff_id,
    s.first_name,
    s.last_name,
    d.specialty,
    d.doctor_rank
ORDER BY
    main_surgeon_procedure_count DESC,
    shift_count_current_year DESC,
    d.staff_id;
