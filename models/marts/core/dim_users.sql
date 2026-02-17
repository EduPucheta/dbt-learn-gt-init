
with users as (

    select * from {{ ref('stg_profiles') }} 

)

select * from users
