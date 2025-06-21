WITH
  initial_value AS (
  SELECT
    av.first_day_of_month,
    pro.underlying_product_name,
    SUM(av.value) AS value
  FROM
    {{ ref("asset_values") }} AS av
  INNER JOIN
    {{ source("reference", "asset_products") }} AS pro
  ON
    pro.product_name = av.entity_name
  WHERE pro.underlying_product_name IS NOT NULL
  GROUP BY
    av.first_day_of_month,
    pro.underlying_product_name ),
  missing_dates AS (
  SELECT
    dates AS first_day_of_month,
    tv.underlying_product_name,
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
    ac.first_day_of_month,
    pro.underlying_product_name,
    SUM(ac.inflow) AS inflow,
    SUM(ac.outflow) AS outflow
  FROM
    {{ ref("asset_cashflows") }} AS ac
  INNER JOIN
    {{ source("reference", "asset_products") }} AS pro
  ON
    pro.product_name = ac.entity_name
  GROUP BY
    ac.first_day_of_month,
    pro.underlying_product_name )
SELECT
  tv.underlying_product_name AS entity_name,
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
  AND tcf.underlying_product_name = tv.underlying_product_name
LEFT JOIN
  {{ ref("profit_consolidated_per_underlying") }} AS apa
ON
  apa.first_day_of_month = tv.first_day_of_month
  AND apa.underlying_product_name = tv.underlying_product_name
ORDER BY
  tv.first_day_of_month ASC