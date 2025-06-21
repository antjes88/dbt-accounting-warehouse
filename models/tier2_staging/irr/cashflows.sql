{{ config (
    materialized="table",
)
}}

SELECT
  entity_name,
  --'accounts' as ledger_name,
  first_day_of_month,
  value,
  inflow,
  outflow
FROM {{ ref("irr_all_accounts") }} 
UNION ALL
SELECT
  entity_name,
  --'total_portfolio' as ledger_name,
  first_day_of_month,
  value,
  inflow,
  outflow
FROM {{ ref("irr_total_portfolio") }}
UNION ALL
SELECT
  entity_name,
  --'total_funds' as ledger_name,
  first_day_of_month,
  value,
  inflow,
  outflow
FROM {{ ref("irr_total_funds") }}
UNION ALL
SELECT
  entity_name,
  --'total_shares' as ledger_name,
  first_day_of_month,
  value,
  inflow,
  outflow
FROM {{ ref("irr_total_shares") }}
UNION ALL
SELECT
  entity_name,
  --'total_private_pension' as ledger_name,
  first_day_of_month,
  value,
  inflow,
  outflow
FROM {{ ref("irr_total_privatepension") }}
UNION ALL
SELECT
  entity_name,
  --'companies' as ledger_name,
  first_day_of_month,
  value,
  inflow,
  outflow
FROM {{ ref("irr_per_company") }}
UNION ALL
SELECT
  entity_name,
  --'underlying_products' as ledger_name,
  first_day_of_month,
  value,
  inflow,
  outflow
FROM {{ ref("irr_per_underlying") }}