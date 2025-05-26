{{ config (
    materialized="table",
)
}}

SELECT
  entity_name,
  first_day_of_month,
  value,
  inflow,
  outflow
FROM {{ ref("irr_all_accounts") }} 
UNION ALL
SELECT
  entity_name,
  first_day_of_month,
  value,
  inflow,
  outflow
FROM {{ ref("irr_total_portfolio") }}
UNION ALL
SELECT
  entity_name,
  first_day_of_month,
  value,
  inflow,
  outflow
FROM {{ ref("irr_total_funds") }}
UNION ALL
SELECT
  entity_name,
  first_day_of_month,
  value,
  inflow,
  outflow
FROM {{ ref("irr_total_shares") }}
UNION ALL
SELECT
  entity_name,
  first_day_of_month,
  value,
  inflow,
  outflow
FROM {{ ref("irr_total_privatepension") }}