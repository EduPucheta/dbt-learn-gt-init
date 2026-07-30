with source as (

    select * from {{ source('raw', 'user_quotas') }}

),

renamed as (

    select
        user_id,
        tokens_used,
        monthly_cap,
        quota_reset_date,
        created_at,
        updated_at,
        _fivetran_deleted

    from source

)

select * from renamed
