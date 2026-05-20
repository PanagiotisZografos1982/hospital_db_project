USE hospital_db;

/* Q05
   Νέοι ιατροί ηλικίας < 35 που έχουν εκτελέσει τις περισσότερες
   χειρουργικές επεμβάσεις ως κύριοι χειρουργοί.
*/
WITH young_doctor_surgeries AS (
    SELECT
        d.staff_id AS doctor_id,
        s.first_name,
        s.last_name,
        s.age,
        d.specialty,
        COUNT(mp.procedure_code) AS surgical_procedure_count
    FROM doctor d
    JOIN staff s
        ON d.staff_id = s.staff_id
    LEFT JOIN performed_procedure pp
        ON d.staff_id = pp.main_surgeon_id
    LEFT JOIN medical_procedure mp
        ON pp.procedure_code = mp.procedure_code
       AND LOWER(mp.category) = 'χειρουργική'
    WHERE s.age < 35
    GROUP BY
        d.staff_id,
        s.first_name,
        s.last_name,
        s.age,
        d.specialty
), ranked AS (
    SELECT
        yds.*,
        DENSE_RANK() OVER (ORDER BY surgical_procedure_count DESC) AS surgery_rank
    FROM young_doctor_surgeries yds
)
SELECT
    doctor_id,
    first_name,
    last_name,
    age,
    specialty,
    surgical_procedure_count
FROM ranked
WHERE surgery_rank = 1
ORDER BY doctor_id;
