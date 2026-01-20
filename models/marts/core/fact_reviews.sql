{{ config(materialized='table') }}

select
    r.survey,
    r.rating
from {{ ref('stg_reviews') }} r

