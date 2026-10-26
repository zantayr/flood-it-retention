-- Daily cohort retention (D1 / D7) for the Flood-It public Firebase dataset.
-- Cohort = the first date a user appears in the export.
WITH first AS (
  SELECT
    user_pseudo_id,
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS first_day
  FROM `firebase-public-project.analytics_153293282.events_*`
  GROUP BY 1
),
act AS (
  SELECT DISTINCT
    user_pseudo_id,
    PARSE_DATE('%Y%m%d', event_date) AS d
  FROM `firebase-public-project.analytics_153293282.events_*`
)
SELECT
  f.first_day AS cohort,
  COUNT(DISTINCT f.user_pseudo_id) AS users,
  ROUND(100 * COUNT(DISTINCT IF(DATE_DIFF(a.d, f.first_day, DAY) = 1, a.user_pseudo_id, NULL))
        / COUNT(DISTINCT f.user_pseudo_id), 1) AS d1_pct,
  ROUND(100 * COUNT(DISTINCT IF(DATE_DIFF(a.d, f.first_day, DAY) = 7, a.user_pseudo_id, NULL))
        / COUNT(DISTINCT f.user_pseudo_id), 1) AS d7_pct
FROM first f
JOIN act a USING (user_pseudo_id)
GROUP BY 1
ORDER BY 1;
