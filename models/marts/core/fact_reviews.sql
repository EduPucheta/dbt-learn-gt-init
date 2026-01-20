{{ config(materialized='table') }}

select
    r.survey,
    r.rating,
    s.user_id
from {{ ref('stg_reviews') }} r
left join {{ ref('stg_surveys') }} s on cast(r.survey as string) = cast(s.survey_id as string)

