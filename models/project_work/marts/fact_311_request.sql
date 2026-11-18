-- Grain: one row per DOT 311 service request.
-- Only CLOSED status is treated as resolved.
-- Date keys: 0 = Unknown; -1 = Not yet closed.

with requests as (
    select *
    from {{ ref('stg_project_311') }}
),

dates as (
    select *
    from {{ ref('dim_project_date') }}
),

locations as (
    select *
    from {{ ref('dim_project_location') }}
),

problems as (
    select *
    from {{ ref('dim_311_problem') }}
),

statuses as (
    select *
    from {{ ref('dim_311_status') }}
)

select
    farm_fingerprint(r.unique_key) as request_key,
    r.unique_key,

    coalesce(cd.date_key, 0) as created_date_key,

    case
        when s.is_resolved then coalesce(cld.date_key, 0)
        else -1
    end as closed_date_key,

    coalesce(l.location_key, 0) as location_key,
    p.problem_key,
    s.status_key,

    case
        when s.is_resolved
            and r.closed_date >= r.created_date
        then date_diff(r.closed_date, r.created_date, day)
        else null
    end as resolution_days,

    1 as request_count

from requests as r

left join dates as cd
    on r.created_date = cd.full_date

left join dates as cld
    on r.closed_date = cld.full_date

left join locations as l
    on (
        r.zip_code = l.zip_code
        or (r.zip_code is null and l.zip_code is null)
    )
    and (
        r.borough = l.borough
        or (r.borough is null and l.borough is null)
    )

left join problems as p
    on coalesce(r.complaint_type, 'Unknown') = p.problem
    and (
        r.descriptor = p.problem_detail
        or (r.descriptor is null and p.problem_detail is null)
    )

left join statuses as s
    on coalesce(upper(trim(r.status)), 'UNKNOWN') = s.status