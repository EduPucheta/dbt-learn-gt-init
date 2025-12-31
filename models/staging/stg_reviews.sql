{{
  config(
    materialized='view'
  )
}}

select
    survey,
    rating,
    _fivetran_deleted
from {{ source('raw', 'reviews') }}
where coalesce(_fivetran_deleted, false) = false

