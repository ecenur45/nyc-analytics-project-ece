-- Grain: one row per observed severity category,
-- plus an unknown member.

with classified as (
    select
        case
            when persons_killed > 0 then 3
            when persons_killed = 0
                and persons_injured > 0 then 2
            when persons_killed = 0
                and persons_injured = 0 then 1
            else 0
        end as severity_key
    from {{ ref('stg_project_collisions') }}
),

severity_keys as (
    select distinct severity_key
    from classified

    union distinct

    select 0 as severity_key
)

select
    severity_key,
    case severity_key
        when 3 then 'Fatal'
        when 2 then 'Injury'
        when 1 then 'No Injury'
        else 'Unknown'
    end as severity_category
from severity_keys