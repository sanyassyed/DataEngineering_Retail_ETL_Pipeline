-- default is incremental but here we just want it as table
{{ config(materialized='table') }}

select
    dd.d_date_sk,
    dd.cal_dt -- matches calendar_dt column in dim_calendar table
from {{ ref('stg_tpcds__date_dim') }} dd
