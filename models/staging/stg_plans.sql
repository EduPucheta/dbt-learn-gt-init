with source as (

    select * from {{ source('raw', 'plans') }}

),

renamed as (

    select
        id as plan_id,
        plan_name,
        plan_monthly_token_quota,
        plan_monthly_responses,
        created_at,
        _fivetran_deleted

    from source

)

select * from renamed
