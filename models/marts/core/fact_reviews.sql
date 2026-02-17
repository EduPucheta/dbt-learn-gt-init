{{ config(materialized='table') }}

select
    r.survey,
    r.rating,
    s.user_id,
    u.plan
from {{ ref('stg_reviews') }} r 
left join {{ ref('stg_surveys') }} s on cast(r.survey as string) = cast(s.survey_id as string)
left join {{ ref('dim_users') }} u on s.user_id = u.user_id