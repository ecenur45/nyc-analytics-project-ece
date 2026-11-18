-- Grain: one row per distinct request status.

with statuses as (
    select distinct
        coalesce(upper(trim(status)), 'UNKNOWN') as status
    from {{ ref('stg_project_311') }}
)

select
    farm_fingerprint(status) as status_key,
    status,
    status = 'CLOSED' as is_resolved
from statuses