{{ config (
    materialized="view",
)
}}

SELECT
  av.first_day_of_month,
  av.entity_name,
  av.value,
  COALESCE(ac.inflow, 0) AS inflow,
  COALESCE(ac.outflow, 0) AS outflow
FROM {{ ref("asset_values") }} AS av
LEFT JOIN {{ ref("asset_cashflows") }} AS ac
ON
  av.first_day_of_month = ac.first_day_of_month
  AND av.entity_name = ac.entity_name
WHERE
  av.first_day_of_month NOT IN ('2023-06-01',
    '2023-07-01',
    '2023-08-01',
    '2023-09-01',
    '2023-10-01')
  AND NOT ( av.entity_name = 'DeGiro - IPCO'
    AND av.first_day_of_month = '2019-04-01' )
UNION ALL
SELECT
  generated AS first_day_of_month,
  ass.entity_name,
  ass.value,
  COALESCE(ac.inflow, 0) AS inflow,
  COALESCE(ac.outflow, 0) AS outflow
FROM
  UNNEST(GENERATE_DATE_ARRAY(DATE '2023-06-01', DATE '2023-10-01', INTERVAL 1 MONTH)) AS generated
CROSS JOIN {{ ref("asset_values") }} AS ass
LEFT JOIN {{ ref("asset_cashflows") }} AS ac
ON
  generated = ac.first_day_of_month
  AND ass.entity_name = ac.entity_name
WHERE
  ass.first_day_of_month = '2023-05-01'