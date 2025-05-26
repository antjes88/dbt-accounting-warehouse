{{ config (
    materialized="view",
)
}}

SELECT
  acc.account_name AS entity_name,
  DATE_ADD(DATE_TRUNC(tran.transaction_date, MONTH), INTERVAL 1 MONTH) AS first_day_of_month,
  SUM(
    CASE
      WHEN UPPER(et.entry_type_name) = 'CREDIT' AND UPPER(aty.account_type_name) <> 'REVENUE' THEN 0
      WHEN UPPER(et.entry_type_name) = 'DEDIT'
    AND UPPER(aty.account_type_name) = 'REVENUE' THEN 0
      WHEN ap.product_currency = 'Euro' THEN ROUND(le.amount * ratio.ratio_to_gbp, 2)
    ELSE
    le.amount
  END
    ) AS inflow,
  SUM(
    CASE
      WHEN UPPER(et.entry_type_name) = 'CREDIT' AND UPPER(aty.account_type_name) <> 'REVENUE' AND ap.product_currency = 'Euro' THEN ROUND(le.amount * ratio.ratio_to_gbp, 2)
      WHEN UPPER(et.entry_type_name) = 'CREDIT'
    AND UPPER(aty.account_type_name) <> 'REVENUE' THEN le.amount
      WHEN UPPER(et.entry_type_name) = 'DEDIT' AND UPPER(aty.account_type_name) = 'REVENUE' AND ap.product_currency = 'Euro' THEN ROUND(le.amount * ratio.ratio_to_gbp, 2)
      WHEN UPPER(et.entry_type_name) = 'DEDIT'
    AND UPPER(aty.account_type_name) = 'REVENUE' THEN le.amount
    ELSE
    0
  END
    ) AS outflow
FROM {{ source("raw", "ledger_entries") }} AS le
INNER JOIN {{ source("raw", "accounts") }} AS acc
ON
  le.account_id = acc.account_id
INNER JOIN {{ source("raw", "transactions") }} AS tran
ON
  le.transaction_id = tran.transaction_id
INNER JOIN {{ source("raw", "entry_types") }} AS et
ON
  le.entry_type_id = et.entry_type_id
INNER JOIN {{ source("raw", "account_types") }} AS aty
ON
  acc.account_type_id = aty.account_type_id
INNER JOIN {{ source("reference", "asset_products") }} AS ap
ON
  acc.account_name = ap.product_name
LEFT JOIN {{ ref("euro_exchange_rates") }} AS ratio
ON
  tran.transaction_date = ratio.date
WHERE
  ap.product_family = 'Stock Market'
GROUP BY
  first_day_of_month,
  acc.account_name
