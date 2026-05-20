USE hospital_db;

/*
Q12
Απαιτούμενος και ανατεθειμένος αριθμός προσωπικού ανά τμήμα και βάρδια
για συγκεκριμένη εβδομάδα, με ανάλυση ανά υποκλάση προσωπικού:
- ιατροί ανά ειδικότητα,
- νοσηλευτές ανά βαθμίδα,
- διοικητικό προσωπικό ανά ρόλο.
*/

SET @week_start := '2026-05-01';
SET @week_end := DATE_ADD(@week_start, INTERVAL 6 DAY);

WITH shift_counts AS (
    SELECT
        sh.shift_id,
        dep.department_id,
        dep.name AS department_name,
        sh.shift_date,
        sh.shift_type,
        SUM(CASE WHEN st.staff_type = 'DOCTOR' THEN 1 ELSE 0 END) AS doctors_assigned,
        SUM(CASE WHEN st.staff_type = 'NURSE' THEN 1 ELSE 0 END) AS nurses_assigned,
        SUM(CASE WHEN st.staff_type = 'ADMIN' THEN 1 ELSE 0 END) AS admins_assigned
    FROM shift sh
    JOIN department dep
        ON sh.department_id = dep.department_id
    LEFT JOIN shift_assignment sa
        ON sh.shift_id = sa.shift_id
    LEFT JOIN staff st
        ON sa.staff_id = st.staff_id
    WHERE sh.shift_date BETWEEN @week_start AND @week_end
    GROUP BY
        sh.shift_id,
        dep.department_id,
        dep.name,
        sh.shift_date,
        sh.shift_type
), subclass_counts AS (
    SELECT
        sh.shift_id,
        st.staff_type,
        CASE
            WHEN st.staff_type = 'DOCTOR' THEN doc.specialty
            WHEN st.staff_type = 'NURSE' THEN nur.nurse_rank
            WHEN st.staff_type = 'ADMIN' THEN adm.role
            ELSE 'UNKNOWN'
        END AS staff_subclass,
        COUNT(*) AS subclass_assigned_count
    FROM shift sh
    JOIN shift_assignment sa
        ON sh.shift_id = sa.shift_id
    JOIN staff st
        ON sa.staff_id = st.staff_id
    LEFT JOIN doctor doc
        ON st.staff_id = doc.staff_id
    LEFT JOIN nurse nur
        ON st.staff_id = nur.staff_id
    LEFT JOIN administrative_staff adm
        ON st.staff_id = adm.staff_id
    WHERE sh.shift_date BETWEEN @week_start AND @week_end
    GROUP BY
        sh.shift_id,
        st.staff_type,
        staff_subclass
)
SELECT
    sc.department_id,
    sc.department_name,
    sc.shift_date,
    sc.shift_type,
    sc.doctors_assigned,
    3 AS doctors_required,
    sc.doctors_assigned - 3 AS doctors_surplus,
    sc.nurses_assigned,
    6 AS nurses_required,
    sc.nurses_assigned - 6 AS nurses_surplus,
    sc.admins_assigned,
    2 AS admins_required,
    sc.admins_assigned - 2 AS admins_surplus,
    sub.staff_type,
    sub.staff_subclass,
    sub.subclass_assigned_count
FROM shift_counts sc
LEFT JOIN subclass_counts sub
    ON sc.shift_id = sub.shift_id
ORDER BY
    sc.department_id,
    sc.shift_date,
    FIELD(sc.shift_type, 'πρωινή', 'απογευματινή', 'νυχτερινή'),
    sub.staff_type,
    sub.staff_subclass;
