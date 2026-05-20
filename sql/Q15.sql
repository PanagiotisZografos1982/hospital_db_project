USE hospital_db;

/*
Q15
Κατανομή triage ανά επίπεδο επείγοντος, μέσος χρόνος αναμονής,
ποσοστό περιστατικών που οδήγησαν σε νοσηλεία και κατανομή παραπομπών ανά τμήμα.

Σημαντική παραδοχή:
- Στο πλήθος περιστατικών μετράμε όλα τα triage cases.
- Στον μέσο χρόνο αναμονής μετράμε μόνο όσα έχουν service_time.
*/

WITH grouped AS (
    SELECT
        tc.urgency_level,
        COALESCE(dep.name, 'Χωρίς παραπομπή') AS referred_department,
        COUNT(*) AS cases_in_group,
        SUM(CASE WHEN tc.hospitalization_id IS NOT NULL THEN 1 ELSE 0 END) AS hospitalizations_in_group,
        SUM(CASE WHEN tc.referred_department_id IS NOT NULL THEN 1 ELSE 0 END) AS referrals_in_group,
        SUM(
            CASE
                WHEN tc.service_time IS NOT NULL
                THEN TIMESTAMPDIFF(MINUTE, tc.arrival_time, tc.service_time)
                ELSE 0
            END
        ) AS waiting_minutes_sum,
        COUNT(tc.service_time) AS cases_with_service_time
    FROM triage_case tc
    LEFT JOIN department dep
        ON tc.referred_department_id = dep.department_id
    GROUP BY
        tc.urgency_level,
        COALESCE(dep.name, 'Χωρίς παραπομπή')
), urgency_totals AS (
    SELECT
        urgency_level,
        SUM(cases_in_group) AS total_cases_by_urgency,
        SUM(hospitalizations_in_group) AS total_hospitalizations_by_urgency,
        SUM(referrals_in_group) AS total_referrals_by_urgency,
        SUM(waiting_minutes_sum) AS total_waiting_minutes_by_urgency,
        SUM(cases_with_service_time) AS total_cases_with_service_time_by_urgency
    FROM grouped
    GROUP BY urgency_level
)
SELECT
    g.urgency_level,
    ut.total_cases_by_urgency,
    ROUND(
        ut.total_waiting_minutes_by_urgency /
        NULLIF(ut.total_cases_with_service_time_by_urgency, 0),
        2
    ) AS avg_waiting_minutes_by_urgency,
    ROUND(
        100.0 * ut.total_hospitalizations_by_urgency /
        NULLIF(ut.total_cases_by_urgency, 0),
        2
    ) AS hospitalization_percentage_by_urgency,
    g.referred_department,
    g.referrals_in_group AS referral_count_to_department,
    ROUND(
        100.0 * g.referrals_in_group /
        NULLIF(ut.total_referrals_by_urgency, 0),
        2
    ) AS referral_percentage_within_urgency
FROM grouped g
JOIN urgency_totals ut
    ON g.urgency_level = ut.urgency_level
ORDER BY
    g.urgency_level,
    referral_count_to_department DESC,
    g.referred_department;
