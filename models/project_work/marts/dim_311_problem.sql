-- Grain: one row per complaint type and descriptor combination.

with problems as (
    select distinct
        coalesce(complaint_type, 'Unknown') as problem,
        descriptor as problem_detail
    from {{ ref('stg_project_311') }}
)

select
    farm_fingerprint(
        to_json_string(
            struct(problem, problem_detail)
        )
    ) as problem_key,
    problem,
    problem_detail
from problems