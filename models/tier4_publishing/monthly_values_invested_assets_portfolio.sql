{{ config (
    materialized="view",
)
}}


WITH
  max_date AS (
  SELECT
    MAX(month_start) AS max_date
  FROM {{ ref("monthly_periodic_asset_portfolio") }}
)
SELECT
  pas.account_name,
  PAS.underlying_product_name,
  DATE_ADD(pas.date, INTERVAL 1 DAY) AS month_start,
  CASE
    WHEN ass.end_balance_amount_pounds IS NULL THEN 0
  ELSE
  ass.end_balance_amount_pounds
END
  AS value_pounds,
  CASE
    WHEN ass.end_balance_amount_euros IS NULL THEN 0
  ELSE
  ass.end_balance_amount_euros
END
  AS value_euros,
  pas.end_balance_amount_pounds AS invested_pounds,
  pas.end_balance_amount_euros AS invested_euros,
  pas.is_physical,
  pas.is_archived,
  pas.account_type_name,
  pas.father_account_name,
  pas.father_account_type_name,
  pas.father_account_is_physical,
  pas.father_account_is_archived,
  pas.account_family,
  pas.account_category,
  pas.investment_fund_type,
  pas.account_currency,
  pas.company_name,
  pas.company_webpage,
  pas.company_country,
  pas.pension_plan,
  pas.fixed_yield
FROM {{ ref("monthly_periodic_accumulating_stock_market") }} AS pas
LEFT JOIN {{ ref("monthly_periodic_asset_portfolio") }} AS ass
ON
  ass.month_start = DATE_ADD(pas.date, INTERVAL 1 DAY)
  AND ass.account_name = pas.account_name
CROSS JOIN
  max_date md
WHERE
  pas.account_family = 'Stock Market'
  AND DATE_ADD(pas.date, INTERVAL 1 DAY) <= md.max_date
  AND DATE_ADD(pas.date, INTERVAL 1 DAY) NOT IN ('2023-06-01',
    '2023-07-01',
    '2023-08-01',
    '2023-09-01',
    '2023-10-01')
UNION ALL
SELECT
  pas.account_name,
  PAS.underlying_product_name,
  DATE_ADD(pas.date, INTERVAL 1 DAY) AS month_start,
  CASE
    WHEN ass.end_balance_amount_pounds IS NULL THEN 0
  ELSE
  ass.end_balance_amount_pounds
END
  AS value_pounds,
  CASE
    WHEN ass.end_balance_amount_euros IS NULL THEN 0
  ELSE
  ass.end_balance_amount_euros
END
  AS value_euros,
  pas.end_balance_amount_pounds AS invested_pounds,
  pas.end_balance_amount_euros AS invested_euros,
  pas.is_physical,
  pas.is_archived,
  pas.account_type_name,
  pas.father_account_name,
  pas.father_account_type_name,
  pas.father_account_is_physical,
  pas.father_account_is_archived,
  pas.account_family,
  pas.account_category,
  pas.investment_fund_type,
  pas.account_currency,
  pas.company_name,
  pas.company_webpage,
  pas.company_country,
  pas.pension_plan,
  pas.fixed_yield
FROM {{ ref("monthly_periodic_accumulating_stock_market") }} AS pas
LEFT JOIN (
  SELECT
    *
  FROM {{ ref("monthly_periodic_asset_portfolio") }}
  WHERE
    month_start = '2023-05-01' 
) ass
ON
  pas.account_name = ass.account_name
WHERE
  pas.account_family = 'Stock Market'
  AND DATE_ADD(pas.date, INTERVAL 1 DAY) IN ('2023-06-01',
    '2023-07-01',
    '2023-08-01',
    '2023-09-01',
    '2023-10-01')