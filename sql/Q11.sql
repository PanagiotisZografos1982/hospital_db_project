USE hospital_db;

WITH doctor_procedure_counts AS (
    SELECT
        d.staff_id AS doctor_id,
        s.first_name,
        s.last_name,
        d.specialty,
        d.doctor_rank,
        COUNT(pp.performed_id) AS procedure_count_current_year
    FROM doctor d
    JOIN staff s
        ON d.staff_id = s.staff_id
    LEFT JOIN performed_procedure pp
        ON d.staff_id = pp.main_surgeon_id
       AND YEAR(pp.start_datetime) = YEAR(CURDATE())
    GROUP BY
        d.staff_id,
        s.first_name,
        s.last_name,
        d.specialty,
        d.doctor_rank
),
max_procedure_count AS (
    SELECT
        MAX(procedure_count_current_year) AS top_procedure_count
    FROM doctor_procedure_counts
)
SELECT
    dpc.doctor_id,
    dpc.first_name,
    dpc.last_name,
    dpc.specialty,
    dpc.doctor_rank,
    dpc.procedure_count_current_year,
    mpc.top_procedure_count,
    mpc.top_procedure_count - dpc.procedure_count_current_year AS procedure_gap_from_top
FROM doctor_procedure_counts dpc
CROSS JOIN max_procedure_count mpc
WHERE dpc.procedure_count_current_year <= mpc.top_procedure_count - 5
ORDER BY
    procedure_gap_from_top DESC,
    dpc.procedure_count_current_year ASC,
    dpc.doctor_id;