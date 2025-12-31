{{
  config(
    materialized='table'
  )
}}

select
    survey,
    avg(rating) as average_rating
from {{ ref('stg_reviews') }}
group by survey
order by survey asc
