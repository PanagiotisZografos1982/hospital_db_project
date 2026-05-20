USE hospital_db;

/* Q08
   Προσωπικό που δεν έχει προγραμματισμένη εφημερία
   σε συγκεκριμένη ημερομηνία και τμήμα.
*/
SET @target_department_id := 1;
SET @target_shift_date := '2026-05-01';

SELECT
    s.staff_id,
    s.first_name,
    s.last_name,
    s.staff_type,
    CASE
        WHEN d.staff_id IS NOT NULL THEN d.specialty
        WHEN n.staff_id IS NOT NULL THEN n.nurse_rank
        WHEN a.staff_id IS NOT NULL THEN a.role
    END AS staff_subcategory,
    CASE
        WHEN d.staff_id IS NOT NULL THEN 'doctor'
        WHEN n.staff_id IS NOT NULL THEN 'nurse'
        WHEN a.staff_id IS NOT NULL THEN 'administrative_staff'
    END AS staff_class
FROM staff s
LEFT JOIN doctor d
    ON s.staff_id = d.staff_id
LEFT JOIN nurse n
    ON s.staff_id = n.staff_id
LEFT JOIN administrative_staff a
    ON s.staff_id = a.staff_id
WHERE NOT EXISTS (
    SELECT 1
    FROM shift_assignment sa
    JOIN shift sh
        ON sa.shift_id = sh.shift_id
    WHERE sa.staff_id = s.staff_id
      AND sh.department_id = @target_department_id
      AND sh.shift_date = @target_shift_date
)
ORDER BY
    staff_class,
    staff_subcategory,
    s.staff_id;
