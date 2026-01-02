{{
  config(
    materialized='view'
  )
}}

select
    survey,
    rating
from {{ source('raw', 'reviews') }}

