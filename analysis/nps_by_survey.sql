-- Practice: conditional aggregation and ratios, built on the rating_to_sentiment UDF output.
with reviews as (

    select * from {{ ref('fact_reviews') }}

),

scored as (

    select
        survey,
        count(*) as total_reviews,
        countif(rating_sentiment = 'promoter') as promoters,
        countif(rating_sentiment = 'passive') as passives,
        countif(rating_sentiment = 'detractor') as detractors
    from reviews
    group by survey

)

select
    survey,
    total_reviews,
    promoters,
    passives,
    detractors,
    round(100.0 * promoters / total_reviews, 1) as promoter_pct,
    round(100.0 * detractors / total_reviews, 1) as detractor_pct,
    round(100.0 * (promoters - detractors) / total_reviews, 1) as nps_score
from scored
order by nps_score desc
