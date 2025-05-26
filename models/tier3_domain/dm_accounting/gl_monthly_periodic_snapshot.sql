{{ config (
    materialized="table",
)
}}

WITH
  sub_query AS (
  SELECT
    DATE_ADD(DATE_ADD(DATE_TRUNC(tran.transaction_date, MONTH), INTERVAL 1 MONTH), INTERVAL - 1 DAY) AS end_of_month,
    acc.account_name,
    SUM(
      CASE
        WHEN UPPER(et.entry_type_name) = 'CREDIT' AND UPPER(aty.account_type_name) <> 'REVENUE' THEN -1 * le.amount
        WHEN UPPER(et.entry_type_name) = 'DEDIT'
      AND UPPER(aty.account_type_name) = 'REVENUE' THEN -1 * le.amount
      ELSE
      le.amount
    END
      ) AS amount
  FROM {{ source("raw", "ledger_entries") }} AS le
  INNER JOIN {{ source("raw", "accounts") }} AS acc
  ON
    le.account_id = acc.account_id
  INNER JOIN {{ source("raw", "transactions") }} AS tran
  ON
    tran.transaction_id = le.transaction_id
  INNER JOIN {{ source("raw", "entry_types") }} AS et
  ON
    et.entry_type_id = le.entry_type_id
  INNER JOIN {{ source("raw", "account_types") }} AS aty
  ON
    acc.account_type_id = aty.account_type_id
  WHERE
    acc.father_account_id IS NOT NULL
  GROUP BY
    end_of_month,
    acc.account_name
  ORDER BY
    acc.account_name,
    end_of_month )
SELECT
  'Accounting App' AS ledger_book_name,
  CAST(psquery.end_of_month AS DATE) AS date,
  acct.account_id,
  CASE
    WHEN acct.account_family = 'Stock Market' AND acct.account_currency = 'Euro' THEN ROUND(psquery.amount * ratio.ratio_to_gbp, 2)
  ELSE
  ROUND(psquery.amount, 2)
END
  AS end_balance_amount_pounds,
  CASE
    WHEN acct.account_family = 'Stock Market' AND acct.account_currency = 'Euro' THEN ROUND(psquery.amount, 2)
  ELSE
  ROUND(psquery.amount / ratio.ratio_to_gbp, 2)
END
  AS end_balance_amount_euros,
  CURRENT_TIMESTAMP() AS created_date,
  'SYSTEM' AS created_by
FROM
  sub_query AS psquery
LEFT JOIN {{ ref("accounts") }} AS acct
ON
  UPPER(acct.account_name) = UPPER(psquery.account_name)
LEFT JOIN {{ ref("euro_exchange_rates") }} AS ratio
ON
  psquery.end_of_month = ratio.date
UNION ALL
SELECT
  'Asset Accounting' AS ledger_book_name,
  av.date,
  acc.account_id,
  CASE
    WHEN ap.product_currency = 'Pound' THEN ROUND(av.value, 2)
  ELSE
  ROUND(av.value * ratio.ratio_to_gbp, 2)
END
  AS end_balance_amount_pounds,
  CASE
    WHEN ap.product_currency = 'Euro' THEN ROUND(av.value, 2)
  ELSE
  ROUND(av.value / ratio.ratio_to_gbp, 2)
END
  AS end_balance_amount_euros,
  CURRENT_TIMESTAMP() AS created_date,
  'SYSTEM' AS created_by
FROM {{ source("raw", "asset_valuations") }} as av
LEFT JOIN {{ source("reference", "asset_products") }} as ap
ON
  ap.product_name = av.product_name
LEFT JOIN {{ ref("accounts") }} AS acc
ON
  acc.account_name = ap.product_name
LEFT JOIN {{ ref("euro_exchange_rates") }} AS ratio
ON
  av.date = ratio.date