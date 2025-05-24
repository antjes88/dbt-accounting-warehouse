{{ config (
    materialized="view",
)
}}

WITH amounts AS (
  SELECT
    MAX_DATE.max_date AS month_start,
    ACC.account_currency,
    ACC.company_name,
    ACC.company_type,
    ACC.company_webpage,
    ACC.company_country,
    SUM(MAS.end_balance_amount_euros) AS total_euros
  FROM {{ ref("gl_monthly_periodic_snapshot") }} AS MAS
  INNER JOIN {{ ref("accounts") }} AS ACC
    ON MAS.account_id = ACC.account_id
  CROSS JOIN (
    SELECT
      DATE_TRUNC(MAX(date), MONTH) AS max_date
    FROM {{ ref("gl_monthly_periodic_snapshot") }}
    WHERE
      ledger_book_name = 'Asset Accounting'
  ) MAX_DATE
  WHERE
    MAS.ledger_book_name = 'Asset Accounting'
    AND DATE_TRUNC(MAS.date, MONTH) = MAX_DATE.max_date
    AND ACC.company_name IS NOT NULL
  GROUP BY
    MAX_DATE.max_date,
    ACC.account_currency,
    ACC.company_name,
    ACC.company_type,
    ACC.company_webpage,
    ACC.company_country
)
SELECT
  amt.month_start,
  amt.account_currency,
  amt.company_name,
  amt.company_type,
  amt.company_webpage,
  amt.company_country,
  r.value
FROM
  amounts amt
LEFT JOIN
  {{ source("reference", "mm_presentation_ranges") }} r
  ON amt.total_euros >= r.min_val AND amt.total_euros < r.max_val
ORDER BY
  r.value
