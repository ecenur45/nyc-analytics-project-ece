-- Grain: one row per raw DOT 311 request record

select
    nullif(trim(unique_key), '') as unique_key,
    created_date as created_at,
    closed_date as closed_at,
    date(created_date) as created_date,
    date(closed_date) as closed_date,

    nullif(upper(trim(agency)), '') as agency,
    nullif(trim(complaint_type), '') as complaint_type,
    nullif(trim(descriptor), '') as descriptor,
    nullif(trim(status), '') as status,

    nullif(upper(trim(borough)), '') as borough,
    nullif(trim(incident_zip), '') as zip_code

from {{ source(
    'nyc_project_raw',
    'source_311_dot_requests'
) }}