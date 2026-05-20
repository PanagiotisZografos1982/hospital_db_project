USE hospital_db;

/*
Q10
Top-3 ζεύγη δραστικών ουσιών που συνταγογραφήθηκαν ταυτόχρονα
στον ίδιο ασθενή κατά την ίδια νοσηλεία.

Η λέξη "ταυτόχρονα" υλοποιείται με έλεγχο χρονικής επικάλυψης
των διαστημάτων [start_date, end_date]. Αν end_date είναι NULL,
θεωρείται ανοικτή θεραπεία.
*/

WITH overlapping_substance_pairs AS (
    SELECT
        LEAST(ms1.substance_id, ms2.substance_id) AS substance_1_id,
        GREATEST(ms1.substance_id, ms2.substance_id) AS substance_2_id,
        p1.patient_id,
        p1.hospitalization_id,
        p1.prescription_id AS prescription_1_id,
        p2.prescription_id AS prescription_2_id
    FROM prescription p1
    JOIN prescription p2
        ON p1.patient_id = p2.patient_id
       AND p1.hospitalization_id = p2.hospitalization_id
       AND p1.prescription_id < p2.prescription_id
       AND p1.hospitalization_id IS NOT NULL
       AND p2.hospitalization_id IS NOT NULL
       AND p1.start_date <= COALESCE(p2.end_date, '9999-12-31')
       AND p2.start_date <= COALESCE(p1.end_date, '9999-12-31')
    JOIN medication_substance ms1
        ON p1.medication_id = ms1.medication_id
    JOIN medication_substance ms2
        ON p2.medication_id = ms2.medication_id
    WHERE ms1.substance_id <> ms2.substance_id
), normalized_pairs AS (
    SELECT DISTINCT
        substance_1_id,
        substance_2_id,
        patient_id,
        hospitalization_id,
        prescription_1_id,
        prescription_2_id
    FROM overlapping_substance_pairs
)
SELECT
    np.substance_1_id,
    a1.name AS substance_1_name,
    np.substance_2_id,
    a2.name AS substance_2_name,
    COUNT(*) AS co_prescription_count
FROM normalized_pairs np
JOIN active_substance a1
    ON np.substance_1_id = a1.substance_id
JOIN active_substance a2
    ON np.substance_2_id = a2.substance_id
GROUP BY
    np.substance_1_id,
    a1.name,
    np.substance_2_id,
    a2.name
ORDER BY
    co_prescription_count DESC,
    np.substance_1_id ASC,
    np.substance_2_id ASC
LIMIT 3;
