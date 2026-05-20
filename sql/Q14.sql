WITH category_year_admissions AS (
    SELECT
        icd.category AS icd10_category,
        YEAR(h.admission_date) AS admission_year,
        COUNT(*) AS admission_count
    FROM hospitalization h
    JOIN icd10_diagnosis icd
        ON h.admission_icd10_code = icd.icd10_code
    GROUP BY
        icd.category,
        YEAR(h.admission_date)
    HAVING COUNT(*) >= 5
)
SELECT
    c1.icd10_category,
    c1.admission_year AS first_year,
    c2.admission_year AS next_year,
    c1.admission_count AS first_year_admissions,
    c2.admission_count AS next_year_admissions
FROM category_year_admissions c1
JOIN category_year_admissions c2
    ON c1.icd10_category = c2.icd10_category
    AND c2.admission_year = c1.admission_year + 1
    AND c1.admission_count = c2.admission_count
ORDER BY
    c1.icd10_category,
    c1.admission_year;
