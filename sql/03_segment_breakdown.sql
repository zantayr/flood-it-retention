-- Tests the hypothesis "September's D1 drop came from low-quality acquisition".
-- Compares Jul–Aug vs September cohorts by platform and first-touch traffic source.
WITH ev AS (
  SELECT DISTINCT
    user_pseudo_id,
    PARSE_DATE('%Y%m%d', event_date) AS d,
    platform,
    traffic_source.source AS src,
    traffic_source.medium AS med
  FROM `firebase-public-project.analytics_153293282.events_*`
),
first AS (
  SELECT
    user_pseudo_id,
    MIN(d) AS first_day,
    ANY_VALUE(platform) AS platform,
    ANY_VALUE(src) AS src,
    ANY_VALUE(med) AS med
  FROM ev
  GROUP BY 1
),
c AS (
  SELECT
    f.user_pseudo_id, f.first_day, f.platform, f.src, f.med,
    MAX(IF(DATE_DIFF(e.d, f.first_day, DAY) = 1, 1, 0)) AS r1,
    MAX(IF(DATE_DIFF(e.d, f.first_day, DAY) = 7, 1, 0)) AS r7
  FROM first f
  JOIN ev e USING (user_pseudo_id)
  GROUP BY 1, 2, 3, 4, 5
)
SELECT
  IF(first_day >= '2018-09-01', '2_Sep', '1_Jul_Aug') AS period,
  platform, src, med,
  COUNT(*) AS users,
  ROUND(100 * AVG(r1), 1) AS d1_pct,
  ROUND(100 * AVG(r7), 1) AS d7_pct
FROM c
WHERE first_day BETWEEN '2018-07-01' AND '2018-09-26'
GROUP BY 1, 2, 3, 4
HAVING users >= 50
ORDER BY 1, 5 DESC;
