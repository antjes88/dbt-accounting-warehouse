{{ config (
    materialized="view",
)
}}

WITH
  total_gross_wealth AS (
  SELECT
    MAS.date,
    SUM(MAS.end_balance_amount_pounds) AS total_amount
  FROM {{ ref("gl_monthly_periodic_snapshot") }} AS MAS
  INNER JOIN {{ ref("accounts") }} AS ACC
  ON
    MAS.account_id = ACC.account_id
  GROUP BY
    MAS.date ),
  total_portfolio AS (
  SELECT
    MAS.date,
    SUM(MAS.end_balance_amount_pounds) AS total_amount
  FROM {{ ref("gl_monthly_periodic_snapshot") }} AS MAS
  INNER JOIN {{ ref("accounts") }} AS ACC
  ON
    MAS.account_id = ACC.account_id
  WHERE
    account_family = "Stock Market"
  GROUP BY
    MAS.date ),
  total_cash AS (
  SELECT
    MAS.date,
    SUM(MAS.end_balance_amount_pounds) AS total_amount
  FROM {{ ref("gl_monthly_periodic_snapshot") }} AS MAS
  INNER JOIN {{ ref("accounts") }} AS ACC
  ON
    MAS.account_id = ACC.account_id
  WHERE
    account_family = "Bank Account"
  GROUP BY
    MAS.date )
SELECT
  DATE_TRUNC(MAS.date, MONTH) AS month_start,
  FORMAT_DATE('%m', MAS.date) AS month_number,
  FORMAT_DATE('%B', MAS.date) AS month_name,
  FORMAT_DATE('%b', MAS.date) AS short_month_name,
  FORMAT_DATE('%G', MAS.date) AS year,
  FORMAT_DATE('%G%m', MAS.date) AS yyyymm,
  ACC.account_name,
  ACC.underlying_product_name,
  ACC.account_type_name,
  ACC.is_physical,
  ACC.is_archived,
  ACC.father_account_name,
  ACC.father_account_type_name,
  ACC.father_account_is_physical,
  ACC.father_account_is_archived,
  ACC.account_family,
  ACC.account_category,
  ACC.investment_fund_type,
  ACC.account_currency,
  ACC.company_name,
  ACC.company_type,
  ACC.company_webpage,
  ACC.company_country,
  ACC.pension_plan,
  ACC.fixed_yield,
  MAS.end_balance_amount_pounds,
  MAS.end_balance_amount_pounds/GWT.total_amount AS percentage_wealth_gross,
  CASE
    WHEN account_family = "Stock Market" THEN MAS.end_balance_amount_pounds/TP.total_amount
  ELSE
  0
END
  AS percentage_portfolio,
  GWT.total_amount AS gross_wealth_pounds,
  TP.total_amount AS total_porfolio_pounds,
  TC.total_amount AS total_bank_accounts_and_equivalents
FROM {{ ref("gl_monthly_periodic_snapshot") }} AS MAS
INNER JOIN {{ ref("accounts") }} AS ACC
ON
  MAS.account_id = ACC.account_id
INNER JOIN
  total_gross_wealth AS GWT
ON
  MAS.date = GWT.date
INNER JOIN
  total_portfolio AS TP
ON
  MAS.date = TP.date
INNER JOIN
  total_cash AS TC
ON
  MAS.date = TC.date
WHERE
  MAS.ledger_book_name = 'Asset Accounting'
  AND (account_family <> "Debt"
    OR account_family IS NULL)
ORDER BY
  ACC.account_name,
  MAS.date DESC