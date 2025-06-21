WITH
  fund_profits AS (
  SELECT
    ap.first_day_of_month,
    pro.underlying_product_name,
    SUM(ap.profit) AS profit
  FROM
    {{ ref("asset_profits") }} AS ap
  INNER JOIN
    {{ source("reference", "asset_products") }} AS pro
  ON
    pro.product_name = ap.entity_name
  GROUP BY
    ap.first_day_of_month,
    pro.underlying_product_name
 ),
  all_dates AS (
  SELECT
    underlying_product_name,
    first_day_of_month
  FROM (
    SELECT
      DISTINCT underlying_product_name
    FROM
      {{ ref("asset_values") }} av
    INNER JOIN
      {{ source("reference", "asset_products") }} AS pro
    ON
      pro.product_name = av.entity_name ) AS companies
  CROSS JOIN
    UNNEST(GENERATE_DATE_ARRAY( (
        SELECT
          MIN(first_day_of_month)
        FROM
          {{ ref("asset_values") }} av
        INNER JOIN
          {{ source("reference", "asset_products") }} AS pro
        ON
          pro.product_name = av.entity_name
        WHERE
          pro.underlying_product_name = companies.underlying_product_name), (
        SELECT
          MAX(first_day_of_month)
        FROM
          {{ ref("asset_values") }} av
        INNER JOIN
          {{ source("reference", "asset_products") }} AS pro
        ON
          pro.product_name = av.entity_name
        WHERE
          pro.underlying_product_name = companies.underlying_product_name), INTERVAL 1 MONTH )) AS first_day_of_month )
SELECT
  ad.first_day_of_month,
  ad.underlying_product_name,
  SUM(COALESCE(cf.profit, 0)) OVER(PARTITION BY ad.underlying_product_name ORDER BY ad.first_day_of_month) AS profit_accumulated
FROM
  all_dates ad
LEFT JOIN
  fund_profits cf
ON
  cf.first_day_of_month = ad.first_day_of_month
  AND cf.underlying_product_name = ad.underlying_product_name
ORDER BY
  ad.underlying_product_name,
  ad.first_day_of_month