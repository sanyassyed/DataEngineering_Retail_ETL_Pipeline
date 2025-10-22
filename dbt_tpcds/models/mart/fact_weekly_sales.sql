{{ config(
    materialized='incremental',
    unique_key=['warehouse_sk', 'item_sk', 'year_number', 'week_of_year', 'date_sk', 'calendar_dt'],
    incremental_strategy='delete+insert'
) }}
{% if is_incremental() %}

  {% set MAX_CAL_DATE_query %}
    select ifnull(max(calendar_dt), '1900-01-01') from {{this}} as MAX_CAL_DT
  {% endset %}

  {% if execute %}
    {% set MAX_CAL_DT = run_query(MAX_CAL_DATE_query).columns[0][0] %}
  {% endif %}

{% endif %}

SELECT *,
       current_date() as UPDATE_TIME
FROM {{ ref('int__fact_weekly_sales_inventory') }}
where 1=1
    {% if is_incremental() %}
        and calendar_dt >= '{{ MAX_CAL_DT }}'
    {% endif %}