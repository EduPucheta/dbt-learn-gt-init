with source as (

    select * from {{ source('raw', 'surveys') }}

),

renamed as (

    select
        id as survey_id,
    user_id

    from source  

)

select * from renamed
