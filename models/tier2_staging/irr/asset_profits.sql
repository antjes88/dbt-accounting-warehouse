{{ config (
    materialized="view",
)
}}

WITH
  date_ended_entities AS (
  SELECT
    entity_name,
    MAX(first_day_of_month) AS max_date
  FROM {{ ref("asset_values") }}
  GROUP BY
    entity_name
  HAVING
    max_date <> (
    SELECT
      MAX(first_day_of_month)
    FROM {{ ref("asset_values") }}
      ) 
    )
SELECT
  dee.max_date AS first_day_of_month,
  dee.entity_name,
  SUM(outflow - inflow) AS profit
FROM {{ ref("asset_cashflows") }} AS ac
INNER JOIN
  date_ended_entities dee
ON
  dee.entity_name = ac.entity_name
GROUP BY
  dee.max_date,
  dee.entity_name
ORDER BY
  dee.max_date