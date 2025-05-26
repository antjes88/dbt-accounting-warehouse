{{ config (
    materialized="view",
)
}}

SELECT
  acc.account_name,
  ACC.underlying_product_name,
  gla.date,
  gla.end_balance_amount_pounds,
  gla.end_balance_amount_euros,
  acc.is_physical,
  acc.is_archived,
  acc.account_type_name,
  acc.father_account_name,
  acc.father_account_type_name,
  acc.father_account_is_physical,
  acc.father_account_is_archived,
  acc.account_family,
  acc.account_category,
  acc.investment_fund_type,
  acc.account_currency,
  acc.company_name,
  acc.company_webpage,
  acc.company_country,
  acc.pension_plan,
  acc.fixed_yield
FROM {{ ref("accounts") }} AS acc
INNER JOIN {{ ref("gl_monthly_accumulating_snapshot") }} AS gla
ON
  gla.account_id = acc.account_id
WHERE
  acc.account_family = 'Stock Market'
ORDER BY
  acc.account_id DESC,
  gla.date DESC