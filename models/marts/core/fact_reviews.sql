{{ config(materialized='table') }}

select
    r.survey,
    r.rating,
    s.user_id,
    u.plan,
    {{ function('rating_to_sentiment') }}(cast(r.rating as int64)) as rating_sentiment,
    m.description as rating_description
from {{ ref('stg_reviews') }} r
left join {{ ref('stg_surveys') }} s on cast(r.survey as string) = cast(s.survey_id as string)
left join {{ ref('dim_users') }} u on s.user_id = u.user_id
left join {{ ref('rating_sentiment_map') }} m on cast(r.rating as int64) = m.rating