-- Weekly cohort retention with right-censoring handled:
-- D7 is only computed for cohorts that had at least 7 days of observable data.
WITH ev AS (
  SELECT user_pseudo_id, PARSE_DATE('%Y%m%d', event_date) AS d
  FROM `firebase-public-project.analytics_153293282.events_*`
),
first AS (
  SELECT user_pseudo_id, MIN(d) AS first_day
  FROM ev
  GROUP BY 1
),
c AS (
  SELECT
    f.user_pseudo_id,
    f.first_day,
    MAX(IF(DATE_DIFF(e.d, f.first_day, DAY) = 1, 1, 0)) AS r1,
    MAX(IF(DATE_DIFF(e.d, f.first_day, DAY) = 7, 1, 0)) AS r7
  FROM first f
  JOIN ev e USING (user_pseudo_id)
  GROUP BY 1, 2
),
lim AS (
  SELECT MIN(d) AS mn, MAX(d) AS mx FROM ev
)
SELECT
  DATE_TRUNC(first_day, WEEK(MONDAY)) AS cohort_week,
  COUNT(*) AS new_users,
  ROUND(100 * AVG(r1), 1) AS d1_pct,
  ROUND(100 * AVG(IF(first_day <= DATE_SUB(mx, INTERVAL 7 DAY), r7, NULL)), 1) AS d7_pct,
  ANY_VALUE(mn) AS data_start,
  ANY_VALUE(mx) AS data_end
FROM c
CROSS JOIN lim
GROUP BY 1
ORDER BY 1;
