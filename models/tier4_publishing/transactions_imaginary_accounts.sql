{{ config (
    materialized="view",
)
}}


SELECT
  tra.transaction_date,
  DATE_ADD(DATE_ADD(DATE_TRUNC(tra.transaction_date, MONTH), INTERVAL 1 MONTH), INTERVAL -1 DAY) AS transaction_month_end,
  acc1.account_name AS from_account_name,
  acc2.account_name AS to_account_name,
  tra.transaction_amount_euros,
  tra.transaction_amount_pounds
FROM {{ ref("transactions") }} AS tra
INNER JOIN {{ ref("accounts") }} AS acc1
ON
  tra.from_account_id = acc1.account_id
INNER JOIN {{ ref("accounts") }} AS acc2
ON
  tra.to_account_id = acc2.account_id
WHERE
  (acc2.account_name IN ('Emergency Fund Account',
      'Leisure Account',
      'Savings Account',
      'Car Amortization Account',
      'Usual Expenses Account',
      'Training Account')
    OR acc1.account_type_name = 'Revenue'
    OR acc2.account_type_name = 'Expense')
  AND acc1.account_name NOT IN ('Groceries',
    'Phone',
    'Subscriptions')