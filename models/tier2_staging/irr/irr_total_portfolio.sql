{{ config (
    materialized="view",
)
}}

WITH
  initial_value AS (
  SELECT
    first_day_of_month,
    SUM(value) AS value
  FROM {{ ref("asset_values") }} 
  GROUP BY
    first_day_of_month ),
  missing_dates AS (
  SELECT
    dates AS first_day_of_month,
    tv.value
  FROM
    UNNEST(GENERATE_DATE_ARRAY(date '2023-06-01', '2023-10-01', INTERVAL 1 MONTH)) AS dates
  CROSS JOIN
    initial_value tv
  WHERE
    tv.first_day_of_month = '2023-05-01' ),
  total_value AS (
  SELECT
    *
  FROM
    initial_value
  UNION ALL
  SELECT
    *
  FROM
    missing_dates),
  total_cashflows AS (
  SELECT
    first_day_of_month,
    SUM(inflow) AS inflow,
    SUM(outflow) AS outflow
  FROM {{ ref("asset_cashflows") }}
  GROUP BY
    first_day_of_month )
SELECT
  'Total Portfolio' AS entity_name,
  tv.first_day_of_month,
  value + COALESCE(profit_accumulated, 0) AS value,
  COALESCE(tcf.inflow, 0) AS inflow,
  COALESCE(tcf.outflow, 0) AS outflow
FROM
  total_value tv
LEFT JOIN
  total_cashflows tcf
ON
  tcf.first_day_of_month = tv.first_day_of_month
LEFT JOIN {{ ref("profit_consolidated_all") }} AS apa
ON
  apa.first_day_of_month = tv.first_day_of_month
