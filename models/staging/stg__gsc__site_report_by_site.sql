
with source as (

    select * from {{ source('google_search_console', 'site_report_by_site') }}

)


select * from source