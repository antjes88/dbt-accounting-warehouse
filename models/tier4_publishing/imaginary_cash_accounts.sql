{{ config (
    materialized="view",
)
}}

SELECT
  MAS.date,
  EXTRACT(month
  FROM
    MAS.date ) AS month_number,
  FORMAT_DATE('%B', MAS.date) AS month_name,
  FORMAT_DATE('%b', MAS.date) AS short_month_name,
  FORMAT_DATE('%G', MAS.date) AS year,
  FORMAT_DATE('%G%m', MAS.date) AS yyyymm,
  ACC.account_name,
  ACC.account_type_name,
  ACC.is_physical,
  ACC.is_archived,
  ACC.father_account_name,
  ACC.father_account_type_name,
  ACC.father_account_is_physical,
  ACC.father_account_is_archived,
  MAS.end_balance_amount_pounds,
  MAS.end_balance_amount_euros
FROM {{ ref("gl_monthly_accumulating_snapshot") }} AS MAS
INNER JOIN {{ ref("accounts") }} AS ACC
ON
  MAS.account_id = ACC.account_id
WHERE
  MAS.ledger_book_name = 'Accounting App'
  AND ACC.account_name IN ('Landing Account',
    'Leisure Account',
    'Savings Account',
    'Emergency Fund Account',
    'Car Amortization Account',
    'Training Account',
    'Usual Expenses Account',
    'Spain Credit Line')
ORDER BY
  acc.account_name,
  MAS.date DESC
