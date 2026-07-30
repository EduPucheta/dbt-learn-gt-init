with source as (

    select * from {{ source('raw', 'survey_devices') }}

),

renamed as (

    select
        survey_id,
        device_name,
        _fivetran_deleted

    from source

)

select * from renamed
