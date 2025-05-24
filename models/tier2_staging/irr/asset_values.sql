{{ config (
    materialized="view",
)
}}

SELECT
  av.product_name AS entity_name,
  DATE_TRUNC(av.date, month) AS first_day_of_month,
  CASE
    WHEN
      ap.product_currency = 'Euro'
      THEN ROUND(av.value * ratio.ratio_to_gbp, 2)
    ELSE
      av.value
  END
    AS value
FROM {{ source("raw", "asset_valuations") }} AS av
INNER JOIN {{ source("reference", "asset_products") }} AS ap
  ON
    av.product_name = ap.product_name
LEFT JOIN {{ ref("euro_exchange_rates") }} AS ratio
  ON
    DATE_TRUNC(av.date, month) = ratio.date
WHERE
  ap.product_family = 'Stock Market'
