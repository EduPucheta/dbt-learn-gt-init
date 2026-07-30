with source as (

    select * from {{ source('raw', 'ab_tests') }}

),

renamed as (

    select
        id as ab_test_id,
        user_id,
        space_id,
        name,
        description,
        target_url,
        element_selector,
        goal_type,
        goal_selector,
        device_targeting,
        is_active,
        created_at,
        updated_at,
        _fivetran_deleted

    from source

)

select * from renamed
