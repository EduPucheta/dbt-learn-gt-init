-- https://docs.getdbt.com/docs/building-a-dbt-project/building-models/using-custom-database/
{% macro generate_database_name(custom_database_name=none, node=none) -%}
    {%- set default_database = target.database -%}

    {%- if not "prod" in target.name -%}
        {{ default_database }}
    {%- else -%}
        {{ custom_database_name | trim }}
    {%- endif -%}

{%- endmacro %}