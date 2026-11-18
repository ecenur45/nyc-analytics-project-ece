-- Grain: one row per distinct crash hour and minute,
-- plus an unknown member.

with distinct_times as (
    select distinct
        extract(hour from crash_time) as hour,
        extract(minute from crash_time) as minute
    from {{ ref('stg_project_collisions') }}
    where crash_time is not null
)

select
    hour * 60 + minute + 1 as time_key,
    hour,
    minute,
    case
        when hour between 6 and 11 then 'Morning'
        when hour between 12 and 17 then 'Afternoon'
        when hour between 18 and 21 then 'Evening'
        else 'Night'
    end as time_period
from distinct_times

union all

select
    0 as time_key,
    cast(null as int64) as hour,
    cast(null as int64) as minute,
    'Unknown' as time_period