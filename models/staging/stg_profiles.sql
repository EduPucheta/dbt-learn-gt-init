
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
      
     
        has_access,
  
        plan,  
        _fivetran_deleted 

    from source 

)

select * from renamed
 