{{
  config(
    materialized='view'
  )
}}

select
    survey,
    rating,
    created_at
from {{ source('raw', 'reviews') }}  

