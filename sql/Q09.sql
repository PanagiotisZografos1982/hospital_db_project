USE hospital_db;

/* Q09
   Ασθενείς που νοσηλεύτηκαν τον ίδιο συνολικό αριθμό ημερών
   μέσα σε ένα έτος, με συνολική διάρκεια άνω των 15 ημερών.
   Παραδοχή: μετράμε μόνο ολοκληρωμένες νοσηλείες.
*/
WITH patient_year_days AS (
    SELECT
        p.patient_id,
        p.amka,
        p.first_name,
        p.last_name,
        YEAR(h.admission_date) AS hospitalization_year,
        COUNT(h.hospitalization_id) AS hospitalization_count,
        SUM(DATEDIFF(h.discharge_date, h.admission_date)) AS total_hospitalization_days
    FROM patient p
    JOIN hospitalization h
        ON p.patient_id = h.patient_id
    WHERE h.discharge_date IS NOT NULL
    GROUP BY
        p.patient_id,
        p.amka,
        p.first_name,
        p.last_name,
        YEAR(h.admission_date)
),
same_day_groups AS (
    SELECT
        hospitalization_year,
        total_hospitalization_days
    FROM patient_year_days
    WHERE total_hospitalization_days > 15
    GROUP BY
        hospitalization_year,
        total_hospitalization_days
    HAVING COUNT(*) > 1
)
SELECT
    pyd.hospitalization_year,
    pyd.total_hospitalization_days,
    pyd.patient_id,
    pyd.amka,
    pyd.first_name,
    pyd.last_name,
    pyd.hospitalization_count
FROM patient_year_days pyd
JOIN same_day_groups sdg
    ON pyd.hospitalization_year = sdg.hospitalization_year
   AND pyd.total_hospitalization_days = sdg.total_hospitalization_days
ORDER BY
    pyd.hospitalization_year,
    pyd.total_hospitalization_days DESC,
    pyd.patient_id;
