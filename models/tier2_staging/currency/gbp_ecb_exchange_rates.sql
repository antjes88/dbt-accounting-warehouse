{{ config (
    materialized="view"
)
}}


WITH
exchange_rates AS (
  SELECT
    creation_date,
    exchange_rate,
    date
  FROM
    {{ source("raw", "exchange_rates") }}
  WHERE
    quote_currency = 'GBP'
    AND base_currency = 'EUR'
    AND source = 'ECB API'
)

SELECT
  creation_date,
  exchange_rate,
  date
FROM
  exchange_rates
