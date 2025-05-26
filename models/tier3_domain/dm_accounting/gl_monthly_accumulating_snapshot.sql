{{ config (
    materialized="table",
)
}}

WITH
  monthly_account_balances AS (
  SELECT
    DATE_ADD(DATE_ADD(DATE_TRUNC(tran.transaction_date, MONTH), INTERVAL 1 month), INTERVAL - 1 DAY) AS end_of_month,
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
    end_of_month ),
  all_end_of_month AS (
  SELECT
    MIN(tran.transaction_date) AS first_date,
    MAX(tran.transaction_date) AS last_date
  FROM {{ source("raw", "transactions") }} AS tran
    ),
  inter_dates AS (
  SELECT
    i AS end_of_month,
    acc.account_name
  FROM
    UNNEST(GENERATE_DATE_ARRAY((
        SELECT
          first_date
        FROM
          all_end_of_month), (
        SELECT
          last_date
        FROM
          all_end_of_month), INTERVAL 1 DAY)) AS i
  CROSS JOIN {{ source("raw", "accounts") }} AS acc
  WHERE
    acc.father_account_id IS NOT NULL),
  accounts_and_dates AS (
  SELECT
    DISTINCT DATE_ADD(DATE_ADD(DATE_TRUNC(end_of_month, MONTH), INTERVAL 1 month), INTERVAL - 1 DAY) AS end_of_month,
    account_name
  FROM
    inter_dates
  ORDER BY
    end_of_month),
  monthly_account_balances_no_holes AS (
  SELECT
    aad.account_name,
    aad.end_of_month,
    CASE
      WHEN mab.amount IS NOT NULL THEN mab.amount
    ELSE
    0.00
  END
    AS amount
  FROM
    accounts_and_dates aad
  LEFT JOIN
    monthly_account_balances mab
  ON
    mab.account_name = aad.account_name
    AND mab.end_of_month = aad.end_of_month ),
  gl_monthly AS (
  SELECT
    end_of_month,
    account_name,
    SUM(amount) OVER (PARTITION BY account_name ORDER BY end_of_month) AS amount
  FROM
    monthly_account_balances_no_holes
  ORDER BY
    account_name,
    end_of_month)
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
  gl_monthly AS psquery
LEFT JOIN {{ ref("accounts") }} AS acct
ON
  UPPER(acct.account_name) = UPPER(psquery.account_name)
LEFT JOIN {{ ref("euro_exchange_rates") }} AS ratio
ON
  psquery.end_of_month = ratio.date