{{ config (
    materialized="table",
)
}}

SELECT
  tr.transaction_date,
  tr.transaction_description,
  ac1.account_id AS from_account_id,
  ac2.account_id AS to_account_id,
  CASE
    WHEN ac2.account_currency = 'Euro' THEN ROUND(tr.amount, 2)
  ELSE
  ROUND(tr.amount / ratio.ratio_to_gbp, 2)
END
  AS transaction_amount_euros,
  CASE
    WHEN ac2.account_currency = 'Euro' THEN ROUND(tr.amount * ratio.ratio_to_gbp, 2)
  ELSE
  ROUND(tr.amount, 2)
END
  AS transaction_amount_pounds,
  CURRENT_TIMESTAMP() AS created_date,
  'SYSTEM' AS created_by
FROM {{ ref("trans") }} AS tr
INNER JOIN {{ ref("accounts") }} AS ac1
ON
  tr.from_account_name = ac1.account_name
INNER JOIN {{ ref("accounts") }} AS ac2
ON
  tr.to_account_name = ac2.account_name
LEFT JOIN {{ ref("euro_exchange_rates") }} AS ratio
ON
  tr.transaction_date = ratio.date
ORDER BY
  transaction_date ASC