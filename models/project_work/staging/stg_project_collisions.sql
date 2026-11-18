-- Grain: one row per raw collision record

select
    cast(collision_id as int64) as collision_id,
    date(crash_date) as crash_date,
    safe_cast(trim(crash_time) as time) as crash_time,

    nullif(upper(trim(borough)), '') as borough,
    nullif(trim(zip_code), '') as zip_code,

    cast(number_of_persons_injured as int64)
        as persons_injured,
    cast(number_of_persons_killed as int64)
        as persons_killed,
    cast(number_of_pedestrians_injured as int64)
        as pedestrians_injured,
    cast(number_of_pedestrians_killed as int64)
        as pedestrians_killed,
    cast(number_of_cyclist_injured as int64)
        as cyclists_injured,
    cast(number_of_cyclist_killed as int64)
        as cyclists_killed,
    cast(number_of_motorist_injured as int64)
        as motorists_injured,
    cast(number_of_motorist_killed as int64)
        as motorists_killed

from {{ source(
    'nyc_project_raw',
    'source_motor_vehicle_collisions'
) }}