-- Practice: join + group by, comparing review volume/rating/NPS mix across subscription plans.
with users as (

    select * from {{ ref('dim_users') }}

),

reviews as (

    select * from {{ ref('fact_reviews') }}

)

select
    u.plan,
    count(distinct u.user_id) as users_on_plan,
    count(r.rating) as reviews_submitted,
    round(avg(r.rating), 2) as avg_rating,
    countif(r.rating_sentiment = 'promoter') as promoters,
    countif(r.rating_sentiment = 'detractor') as detractors
from users u
left join reviews r on u.user_id = r.user_id
group by u.plan
order by avg_rating desc
