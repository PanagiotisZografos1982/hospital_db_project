WITH RECURSIVE doctor_hierarchy AS (
    SELECT
        d.staff_id AS doctor_id,
        d.supervisor_id AS supervisor_id,
        1 AS hierarchy_level
    FROM doctor d
    WHERE d.supervisor_id IS NOT NULL

    UNION ALL

    SELECT
        dh.doctor_id,
        supervisor.supervisor_id AS supervisor_id,
        dh.hierarchy_level + 1 AS hierarchy_level
    FROM doctor_hierarchy dh
    JOIN doctor supervisor
        ON dh.supervisor_id = supervisor.staff_id
    WHERE supervisor.supervisor_id IS NOT NULL
)
SELECT
    dh.doctor_id,
    doctor_staff.first_name AS doctor_first_name,
    doctor_staff.last_name AS doctor_last_name,
    doctor_info.doctor_rank AS doctor_rank,
    dh.hierarchy_level,
    dh.supervisor_id,
    supervisor_staff.first_name AS supervisor_first_name,
    supervisor_staff.last_name AS supervisor_last_name,
    supervisor_info.doctor_rank AS supervisor_rank,
    supervisor_info.specialty AS supervisor_specialty,
    CASE
        WHEN supervisor_info.doctor_rank = 'Διευθυντής' THEN 'YES'
        ELSE 'NO'
    END AS is_director_level
FROM doctor_hierarchy dh
JOIN doctor doctor_info
    ON dh.doctor_id = doctor_info.staff_id
JOIN staff doctor_staff
    ON doctor_info.staff_id = doctor_staff.staff_id
JOIN doctor supervisor_info
    ON dh.supervisor_id = supervisor_info.staff_id
JOIN staff supervisor_staff
    ON supervisor_info.staff_id = supervisor_staff.staff_id
ORDER BY
    dh.doctor_id,
    dh.hierarchy_level;
