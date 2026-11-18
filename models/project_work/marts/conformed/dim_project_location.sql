{{ config(alias='dim_location') }}

-- Grain: one row per ZIP code and borough combination.
-- Reserved key: 0 = Unknown location.

with locations as (
    select zip_code, borough
    from {{ ref('stg_project_collisions') }}

    union distinct

    select zip_code, borough
    from {{ ref('stg_project_311') }}
)

select
    farm_fingerprint(
        to_json_string(
            struct(zip_code, borough)
        )
    ) as location_key,
    zip_code,
    borough
from locations
where zip_code is not null
   or borough is not null

union all

select
    0 as location_key,
    cast(null as string) as zip_code,
    cast(null as string) as borough