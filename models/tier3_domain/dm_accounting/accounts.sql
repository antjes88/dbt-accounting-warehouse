{{ config (
    materialized="table",
)
}}


SELECT
  ROW_NUMBER() OVER() AS account_id,
  *
FROM (
  SELECT
    acc.account_id AS original_account_id,
    acc.account_name,
    ap.underlying_product_name,
    acc.is_physical,
    acc.is_archived,
    typ.account_type_name,
    accf.account_name AS father_account_name,
    typ2.account_type_name AS father_account_type_name,
    accf.is_physical AS father_account_is_physical,
    accf.is_archived AS father_account_is_archived,
    ap.product_family AS account_family,
    ap.product_category AS account_category,
    ap.investment_fund_type,
    ap.product_currency AS account_currency,
    ap.company_name,
    ap.company_type,
    ap.company_webpage,
    ap.company_country,
    ap.pension_plan,
    ap.fixed_yield,
    CURRENT_TIMESTAMP() AS created_date,
    'SYSTEM' AS created_by
  FROM {{ source("raw", "accounts") }} AS acc
  INNER JOIN {{ source("raw", "account_types") }} AS typ
  ON
    acc.account_type_id = typ.account_type_id
  INNER JOIN {{ source("raw", "accounts") }} AS accf
  ON
    acc.father_account_id = accf.account_id
  INNER JOIN {{ source("raw", "account_types") }} AS typ2
  ON
    accf.account_type_id = typ2.account_type_id
  LEFT JOIN {{ source("reference", "asset_products") }} AS ap
  ON
    acc.account_name = ap.product_name
  WHERE
    acc.father_account_id IS NOT NULL
  UNION ALL
  SELECT
    NULL AS original_account_id,
    ap.product_name,
    ap.underlying_product_name,
    TRUE AS is_physical,
    FALSE AS is_archived,
    ap.account_type_name,
    ap.father_account_name,
    ap.father_account_type_name,
    TRUE AS father_account_is_physical,
    FALSE AS father_account_is_archived,
    ap.product_family AS account_family,
    ap.product_category AS account_category,
    ap.investment_fund_type,
    ap.product_currency AS account_currency,
    ap.company_name,
    ap.company_type,
    ap.company_webpage,
    ap.company_country,
    ap.pension_plan,
    ap.fixed_yield,
    CURRENT_TIMESTAMP() AS created_date,
    'SYSTEM' AS created_by
  FROM {{ source("reference", "asset_products") }} AS ap
  LEFT JOIN {{ source("raw", "accounts") }} AS acc
  ON
    acc.account_name = ap.product_name
  WHERE
    acc.account_name IS NULL)