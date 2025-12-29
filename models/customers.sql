select
    id,
    created_at,
    name,
    rating,
    review,
    user_id,
    survey,
    page,
    category,
    country,
    device,
    browser,
    _fivetran_synced

from `public.reviews`

where _fivetran_deleted = false or _fivetran_deleted is null
