{{ config(alias='dim_date') }}

-- Grain: one row per calendar date, plus special members.
-- Reserved keys: 0 = Unknown; -1 = Not yet closed.

with source_dates as (
    select crash_date as full_date
    from {{ ref('stg_project_collisions') }}

    union all

    select created_date as full_date
    from {{ ref('stg_project_311') }}

    union all

    select closed_date as full_date
    from {{ ref('stg_project_311') }}
),

date_bounds as (
    select
        min(full_date) as min_date,
        max(full_date) as max_date
    from source_dates
    where full_date is not null
),

calendar as (
    select full_date
    from date_bounds,
    unnest(generate_date_array(min_date, max_date)) as full_date
)

select
    cast(format_date('%Y%m%d', full_date) as int64) as date_key,
    full_date,
    extract(day from full_date) as day_of_month,
    extract(month from full_date) as month,
    format_date('%B', full_date) as month_name,
    extract(quarter from full_date) as quarter,
    extract(year from full_date) as year,
    format_date('%A', full_date) as day_of_week
from calendar

union all

select
    0 as date_key,
    cast(null as date) as full_date,
    cast(null as int64) as day_of_month,
    cast(null as int64) as month,
    cast(null as string) as month_name,
    cast(null as int64) as quarter,
    cast(null as int64) as year,
    cast(null as string) as day_of_week

union all

select
    -1 as date_key,
    cast(null as date) as full_date,
    cast(null as int64) as day_of_month,
    cast(null as int64) as month,
    cast(null as string) as month_name,
    cast(null as int64) as quarter,
    cast(null as int64) as year,
    cast(null as string) as day_of_week