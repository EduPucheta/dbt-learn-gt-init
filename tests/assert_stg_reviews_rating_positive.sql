select
    survey,
    rating
from {{ ref('stg_reviews') }}
where rating < 0
