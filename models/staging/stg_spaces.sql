with source as (

    select * from {{ source('raw', 'spaces') }}

),

renamed as (

    select
        id as space_id,
        profile_id as user_id,
        organization_name,
        organization_url,
        created_at,
        updated_at,
        _fivetran_deleted

    from source

)

select * from renamed
