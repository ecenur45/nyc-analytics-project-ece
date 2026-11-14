-- One row per NYC DOB job application filing

WITH source AS (
    SELECT *
    FROM {{ source('raw', 'source_nyc_dob_job_apps') }}
),

cleaned AS (
    SELECT
        * EXCEPT (
            job_filing_number,
            filing_status,
            filing_date,
            current_status_date,
            house_no,
            street_name,
            borough,
            postcode,
            zip,
            latitude,
            longitude,
            initial_cost,
            total_construction_floor_area
        ),

        TRIM(job_filing_number) AS job_filing_number,
        NULLIF(UPPER(TRIM(filing_status)), '') AS filing_status,

        CAST(filing_date AS TIMESTAMP) AS filing_date,
        CAST(current_status_date AS TIMESTAMP) AS current_status_date,

        NULLIF(TRIM(house_no), '') AS house_no,
        NULLIF(UPPER(TRIM(street_name)), '') AS street_name,

        CASE
            WHEN UPPER(TRIM(borough)) IN (
                'MANHATTAN', 'NEW YORK COUNTY', '1'
            ) THEN 'Manhattan'
            WHEN UPPER(TRIM(borough)) IN (
                'BRONX', 'THE BRONX', '2'
            ) THEN 'Bronx'
            WHEN UPPER(TRIM(borough)) IN (
                'BROOKLYN', 'KINGS COUNTY', '3'
            ) THEN 'Brooklyn'
            WHEN UPPER(TRIM(borough)) IN (
                'QUEENS', 'QUEEN', 'QUEENS COUNTY', '4'
            ) THEN 'Queens'
            WHEN UPPER(TRIM(borough)) IN (
                'STATEN ISLAND', 'RICHMOND COUNTY', '5'
            ) THEN 'Staten Island'
            ELSE 'UNKNOWN or CITYWIDE'
        END AS borough,

        CASE
            WHEN REGEXP_CONTAINS(
                TRIM(postcode), r'^\d{5}$'
            ) THEN TRIM(postcode)
            WHEN REGEXP_CONTAINS(
                TRIM(postcode), r'^\d{9}$'
            ) THEN TRIM(postcode)
            WHEN REGEXP_CONTAINS(
                TRIM(postcode), r'^\d{5}-\d{4}$'
            ) THEN TRIM(postcode)
            ELSE NULL
        END AS zip,

        zip AS source_zip,

        SAFE_CAST(latitude AS NUMERIC) AS latitude,
        SAFE_CAST(longitude AS NUMERIC) AS longitude,

        SAFE_CAST(
            REPLACE(REPLACE(TRIM(initial_cost), '$', ''), ',', '')
            AS NUMERIC
        ) AS initial_cost,

        SAFE_CAST(
            REPLACE(TRIM(total_construction_floor_area), ',', '')
            AS NUMERIC
        ) AS total_construction_floor_area,

        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source
    WHERE NULLIF(TRIM(job_filing_number), '') IS NOT NULL
)

SELECT * FROM cleaned