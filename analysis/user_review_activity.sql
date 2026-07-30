-- Practice: window functions (row_number, lag, avg over partition) per user's review history.
with reviews as (

    select
        s.user_id,
        r.survey,
        r.rating,
        r.created_at
    from {{ ref('stg_reviews') }} r
    left join {{ ref('stg_surveys') }} s on cast(r.survey as string) = cast(s.survey_id as string)

),

ranked as (

    select
        user_id,
        survey,
        rating,
        created_at,
        row_number() over (partition by user_id order by created_at desc) as review_recency_rank,
        rating - lag(rating) over (partition by user_id order by created_at) as rating_change_from_previous,
        round(avg(rating) over (partition by user_id), 2) as user_avg_rating
    from reviews
    where user_id is not null

)

select *
from ranked
order by user_id, review_recency_rank
