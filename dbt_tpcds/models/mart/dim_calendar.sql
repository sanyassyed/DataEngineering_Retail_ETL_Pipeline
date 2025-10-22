{{ config(
    materialized='table'
) }}

-- Pull start and end dates from dbt variables (with defaults)
{% set start_date = var('calendar_start_date', '1990-01-01') %}
{% set end_date = var('calendar_end_date', '2030-12-31') %}

-- Generate the calendar
with generated_calendar as (
    {{ generate_dim_calendar(start_date, end_date) }}
),

-- Bring in date_dim from the source
date_dim as (
    select *
    from {{ ref('stg_tpcds__date_dim') }}
)

-- Final join
select
    dd.d_date_sk as date_natural_key,
    gc.*
from generated_calendar gc
left join date_dim dd
    on gc.cal_dt = dd.cal_dt
order by gc.cal_dt
