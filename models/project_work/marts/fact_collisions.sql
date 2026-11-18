-- Grain: one row per motor vehicle collision.
-- Missing injury and fatality counts are preserved as NULL.

with collisions as (
    select *
    from {{ ref('stg_project_collisions') }}
),

dates as (
    select *
    from {{ ref('dim_project_date') }}
),

locations as (
    select *
    from {{ ref('dim_project_location') }}
),

times as (
    select *
    from {{ ref('dim_crash_time') }}
),

severities as (
    select *
    from {{ ref('dim_crash_severity') }}
),

classified as (
    select
        *,
        case
            when persons_killed > 0 then 'Fatal'
            when persons_killed = 0
                and persons_injured > 0 then 'Injury'
            when persons_killed = 0
                and persons_injured = 0 then 'No Injury'
            else 'Unknown'
        end as severity_category
    from collisions
)

select
    c.collision_id as collision_key,
    c.collision_id,

    coalesce(d.date_key, 0) as date_key,
    coalesce(l.location_key, 0) as location_key,
    coalesce(t.time_key, 0) as time_key,
    s.severity_key,

    c.persons_injured,
    c.persons_killed,
    c.pedestrians_injured,
    c.pedestrians_killed,
    c.cyclists_injured,
    c.cyclists_killed,
    c.motorists_injured,
    c.motorists_killed,

    1 as crash_count

from classified as c

left join dates as d
    on c.crash_date = d.full_date

left join locations as l
    on (
        c.zip_code = l.zip_code
        or (c.zip_code is null and l.zip_code is null)
    )
    and (
        c.borough = l.borough
        or (c.borough is null and l.borough is null)
    )

left join times as t
    on extract(hour from c.crash_time) = t.hour
    and extract(minute from c.crash_time) = t.minute

left join severities as s
    on c.severity_category = s.severity_category