select
survey,
avg(rating) as average_rating

from `public.reviews`


where _fivetran_deleted = false or _fivetran_deleted is null

group by survey
order by survey asc
