-- Grain: one row per DOT 311 request.
-- Keep the record with the latest resolution action update.

with ranked_requests as (
    select
        *,
        row_number() over (
            partition by unique_key
            order by
                resolution_action_updated_date desc nulls last
        ) as row_num
    from {{ source(
        'nyc_project_raw',
        'source_311_dot_requests'
    ) }}
)

select
    nullif(trim(unique_key), '') as unique_key,
    created_date as created_at,
    closed_date as closed_at,
    date(created_date) as created_date,
    date(closed_date) as closed_date,

    resolution_action_updated_date,

    nullif(upper(trim(agency)), '') as agency,
    nullif(trim(complaint_type), '') as complaint_type,
    nullif(trim(descriptor), '') as descriptor,
    nullif(trim(status), '') as status,

    nullif(upper(trim(borough)), '') as borough,
    nullif(trim(incident_zip), '') as zip_code

from ranked_requests
where row_num = 1