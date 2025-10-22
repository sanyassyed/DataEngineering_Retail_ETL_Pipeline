-- Pull start and end dates from dbt variables (with defaults)
{% set start_date = var('calendar_start_date', '1990-01-01') %}
{% set end_date = var('calendar_end_date', '2030-12-31') %}

-- Generate the calendar
with generated_calendar as (
    {{ generate_dim_calendar(start_date, end_date) }}
)
select
    cast(to_char(calendar_dt, 'YYYYMMDD') as integer) as date_sk,  -- your new surrogate key
    calendar_dt, -- true DATE field
    year_number,
    month_number,
    month_name,
    quarter_number,
    day_of_month,
    day_of_week_number,
    day_name,
    week_of_year,
    month_start_date,
    month_end_date,
    quarter_start_date,
    year_start_date,
    is_weekend,
    days_in_month,
    year_month_number,
    year_week_number,
    quarter_label
from generated_calendar
order by calendar_dt
