{{ config (
    materialized="view",
)
}}
WITH
transactions AS (
  SELECT
    tra.transaction_id,
    tra.transaction_date,
    tra.transaction_description,
    acc.account_name,
    act.account_type_name,
    et.entry_type_name,
    le.amount
  FROM
    {{ source("raw", "transactions") }} AS tra
  INNER JOIN
    {{ source("raw", "ledger_entries") }} AS le
    ON
      tra.transaction_id = le.transaction_id
  INNER JOIN
    {{ source("raw", "accounts") }} AS acc
    ON
      le.account_id = acc.account_id
  INNER JOIN
    {{ source("raw", "entry_types") }} AS et
    ON
      le.entry_type_id = et.entry_type_id
  INNER JOIN
    {{ source("raw", "account_types") }} AS act
    ON
      acc.account_type_id = act.account_type_id
  ORDER BY
    tra.transaction_id ASC
)

SELECT
  tra1.transaction_date,
  tra1.transaction_description,
  tra1.account_name AS from_account_name,
  tra2.account_name AS to_account_name,
  tra1.account_type_name AS from_account_type_name,
  tra2.account_type_name AS to_account_type_name,
  tra1.amount
FROM
  transactions AS tra1
INNER JOIN
  transactions AS tra2
  ON
    tra1.transaction_id = tra2.transaction_id
    AND tra1.account_name != tra2.account_name
WHERE
  tra1.transaction_id NOT IN (
    SELECT transaction_id
    FROM
      transactions
    WHERE
      account_type_name = 'Revenue'
  )
  AND tra1.entry_type_name = 'Credit'
UNION ALL
SELECT
  tra1.transaction_date,
  tra1.transaction_description,
  tra1.account_name AS from_account_name,
  tra2.account_name AS to_account_name,
  tra1.account_type_name AS from_account_type_name,
  tra2.account_type_name AS to_account_type_name,
  tra1.amount
FROM
  transactions AS tra1
INNER JOIN
  transactions AS tra2
  ON
    tra1.transaction_id = tra2.transaction_id
    AND tra1.account_name != tra2.account_name
WHERE
  tra1.account_type_name = 'Revenue'
ORDER BY
  amount DESC
