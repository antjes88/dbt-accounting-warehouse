{{ config (
    materialized="view",
)
}}

WITH
  fund_profits AS (
    SELECT
      ap.first_day_of_month,
      SUM(ap.profit) AS profit
    FROM {{ ref("asset_profits") }} AS ap 
    INNER JOIN {{ source("reference", "asset_products") }} AS pro
    ON
      pro.product_name = ap.entity_name
    WHERE
      pro.pension_plan
    GROUP BY
      ap.first_day_of_month 
  ),
  all_dates AS (
    SELECT
      first_day_of_month
    FROM
      UNNEST(GENERATE_DATE_ARRAY((
          SELECT
            MIN(first_day_of_month)
          FROM {{ ref("asset_values") }}
            ),(
          SELECT
            MAX(first_day_of_month)
          FROM {{ ref("asset_values") }}
            ), INTERVAL 1 MONTH)) AS first_day_of_month 
)
SELECT
  ad.first_day_of_month,
  SUM(COALESCE(cf.profit, 0)) OVER(ORDER BY ad.first_day_of_month) AS profit_accumulated
FROM
  all_dates ad
LEFT JOIN
  fund_profits cf
ON
  cf.first_day_of_month = ad.first_day_of_month