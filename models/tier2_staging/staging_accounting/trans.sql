{{config (
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
    {{ source("raw", "transactions") }} tra
  INNER JOIN
    {{ source("raw", "ledger_entries") }} le
  ON
    le.transaction_id = tra.transaction_id
  INNER JOIN
    {{ source("raw", "accounts") }} acc
  ON
    acc.account_id = le.account_id
  INNER JOIN
    {{ source("raw", "entry_types") }} et
  ON
    et.entry_type_id = le.entry_type_id
  INNER JOIN
    {{ source("raw", "account_types") }} act
  ON
    act.account_type_id = acc.account_type_id
  ORDER BY
    tra.transaction_id ASC)
SELECT
  tra1.transaction_date,
  tra1.transaction_description,
  tra1.account_name AS from_account_name,
  tra2.account_name AS to_account_name,
  tra1.account_type_name AS from_account_type_name,
  tra2.account_type_name AS to_account_type_name,
  tra1.amount
FROM
  transactions tra1
INNER JOIN
  transactions tra2
ON
  tra1.transaction_id = tra2.transaction_id
  AND tra1.account_name <> tra2.account_name
WHERE
  tra1.transaction_id NOT IN (
  SELECT
    transaction_id
  FROM
    transactions
  WHERE
    account_type_name = 'Revenue')
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
  transactions tra1
INNER JOIN
  transactions tra2
ON
  tra1.transaction_id = tra2.transaction_id
  AND tra1.account_name <> tra2.account_name
WHERE
  tra1.account_type_name = 'Revenue'
ORDER BY
  amount DESC