{{ config(
    materialized='incremental',
    unique_key=['warehouse_sk', 'item_sk', 'year_number', 'week_of_year', 'date_sk'],
    incremental_strategy='insert_overwrite'
) }}

SELECT *
FROM {{ ref('int__fact_weekly_sales_inventory') }}