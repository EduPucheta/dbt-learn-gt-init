with source as (

    select * from {{ source('raw', 'presale_subscribers') }}

),

renamed as (

    select
        id as subscriber_id,
        email,
        subscribed_at,
        created_at,
        _fivetran_deleted

    from source

)

select * from renamed
