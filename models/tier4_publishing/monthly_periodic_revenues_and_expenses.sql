{{ config (
    materialized="view",
)
}}


SELECT
  REV.date,
  SUM(REV.end_balance_amount_pounds) AS revenues_pounds,
  SUM(EXP.end_balance_amount_pounds) AS expenses_pounds,
  SUM(REV.end_balance_amount_euros) AS revenues_euros,
  SUM(EXP.end_balance_amount_euros) AS expenses_euros
FROM (
  SELECT
    date,
    SUM(end_balance_amount_pounds) AS end_balance_amount_pounds,
    SUM(end_balance_amount_euros) AS end_balance_amount_euros
  FROM {{ ref("monthly_periodic_revenues") }}
  GROUP BY
    date ) AS REV
LEFT JOIN (
  SELECT
    date,
    SUM(end_balance_amount_pounds) AS end_balance_amount_pounds,
    SUM(end_balance_amount_euros) AS end_balance_amount_euros
  FROM {{ ref("monthly_periodic_expenses") }}
  GROUP BY
    date ) AS EXP
ON
  REV.date = EXP.date
GROUP BY
  REV.date
ORDER BY
  REV.date DESC