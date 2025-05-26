{{ config (
    materialized="table"
)
}}

WITH
  ecb_exchange_rates AS (
  SELECT
    date,
    creation_date,
    'GBP' AS currency,
    exchange_rate
  FROM
    {{ ref("gbp_ecb_exchange_rates") }}
  UNION ALL
  SELECT
    date,
    creation_date,
    'USD' AS currency,
    exchange_rate
  FROM
    {{ ref("usd_ecb_exchange_rates") }}
  )
  ,row_number AS (
    SELECT
        date,
        currency,
        exchange_rate,
        creation_date,
        ROW_NUMBER() OVER(PARTITION BY date, currency ORDER BY creation_date DESC) AS rn
      FROM ecb_exchange_rates
      ORDER BY
        date DESC,
        currency
  )
  , first_rows AS (
    SELECT
      subq.date,
      subq.currency,
      subq.exchange_rate,
      subq.creation_date
    FROM row_number subq
    WHERE
      subq.rn = 1
  )  
  ,source_rates AS (
  SELECT
    date,
    LEAST(creation_date_USD, creation_date_GBP) AS extraction_date,
    exchange_rate_GBP AS exchange_rate_eur_to_gbp,
    exchange_rate_USD AS exchange_rate_eur_to_usd
  FROM first_rows ex PIVOT ( AVG(ex.exchange_rate) AS exchange_rate, MIN(creation_date) as creation_date FOR ex.currency IN ('GBP','USD') )
  ORDER BY
    date DESC,
    extraction_date),
  all_dates AS (
  SELECT
    i AS date
  FROM
    UNNEST(GENERATE_DATE_ARRAY((
        SELECT
          MIN(date)
        FROM
          source_rates), (
        SELECT
          DATE_ADD(MAX(date), INTERVAL 1 YEAR)
        FROM
          source_rates), INTERVAL 1 DAY)) AS i),
  missing_dates AS (
  SELECT
    ad.date
  FROM
    all_dates ad
  LEFT JOIN
    source_rates ear
  ON
    ad.date = ear.date
  WHERE
    ear.date IS NULL),
  min_dates AS (
  SELECT
    missing_dates.date,
    MAX(ear.date) AS max_date
  FROM
    missing_dates
  INNER JOIN
    source_rates ear
  ON
    missing_dates.date >= ear.date
  GROUP BY
    missing_dates.date)
SELECT
  min_dates.date,
  ear.exchange_rate_eur_to_gbp AS ratio_to_gbp,
  ear.exchange_rate_eur_to_usd AS ratio_to_dollar,
  'Estimation' AS source,
  CURRENT_TIMESTAMP() AS extraction_date
FROM
  min_dates
JOIN
  source_rates ear
ON
  min_dates.max_date = ear.date
UNION ALL
SELECT
  ear.date AS date,
  ear.exchange_rate_eur_to_gbp AS ratio_to_gbp,
  ear.exchange_rate_eur_to_usd AS ratio_to_dollar,
  'ECB' AS source,
  ear.extraction_date
FROM
  source_rates ear
ORDER BY
  date DESC