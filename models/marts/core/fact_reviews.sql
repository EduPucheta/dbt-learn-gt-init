{{ config(materialized='table') }}

select
    r.survey,
    r.rating,
    s.survey_id
from {{ ref('stg_reviews') }} r
left join {{ ref('stg_surveys') }} s on r.survey = s.survey_id

