
{{ config(materialized='view') }}

with source as (

    select * from {{ source('raw', 'profiles') }}

),

renamed as (

    select
        id as user_id,
        name,
        email,
        image,
        customer_id,
        price_id,
        has_access,
        created_at,
        updated_at,
        plan,
        _fivetran_deleted

    from source

)

select * from renamed
