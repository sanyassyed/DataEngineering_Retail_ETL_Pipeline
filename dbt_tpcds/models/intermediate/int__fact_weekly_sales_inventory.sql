{{ config(
    materialized='incremental',
    unique_key=['warehouse_sk', 'item_sk', 'calendar_dt'],
    incremental_strategy='delete+insert'
) }}

{% if is_incremental() %}

  {% set MAX_CAL_DATE_query %}
    select ifnull(max(calendar_dt), '1900-01-01') from {{this}} as MAX_CAL_DT
  {% endset %}

  {% if execute %}
    {% set MAX_CAL_DT = run_query(MAX_CAL_DATE_query).columns[0][0] or '1900-01-01' %}
  {% endif %}

{% endif %}

-- 1) Aggregate daily sales -> weekly
with weekly_sales as (
    select
        warehouse_sk,
        item_sk,
        year_number,
        week_of_year,
        MIN(date_sk) as date_sk,
        MIN(calendar_dt) as calendar_dt,
        sum(coalesce(daily_quantity, 0))   as weekly_quantity,
        sum(coalesce(daily_sales_amt, 0))  as weekly_sales_amt,
        sum(coalesce(daily_net_profit, 0)) as weekly_net_profit,
        avg(coalesce(daily_quantity, 0))   as weekly_avg_quantity
    from {{ ref('int__fact_daily_sales') }}
    group by 1,2,3,4
),

-- 2) Aggregate inventory per week
weekly_inventory as (
    select
        i.inv_warehouse_sk as warehouse_sk,
        i.inv_item_sk      as item_sk,
        d.year_number,
        d.week_of_year,
        sum(coalesce(i.inv_quantity_on_hand, 0)) as sum_weekly_inv_qty,
        avg(coalesce(i.inv_quantity_on_hand, 0)) as avg_daily_inv_qty
    from {{ ref('stg_tpcds__inventory') }} i
    JOIN {{ ref('int__date_bridge')}} b 
    ON i.inv_date_sk = b.d_date_sk 
    join {{ ref('dim_calendar') }} d
      on d.calendar_dt = b.cal_dt
    group by 1,2,3,4
),

-- 3) Get week start date (Sunday) for consistency
week_reference_date as (
    select
        year_number,
        week_of_year,
        min(date_sk) as week_start_date_sk,
        min(calendar_dt) as week_start_calendar_dt
    from {{ ref('dim_calendar') }}
    where day_of_week_number = 0 -- Sunday is the end of the week Monday is 1 and Sunday is 0
    group by 1,2
),

-- 4) FULL OUTER JOIN sales & inventory
sales_inv_union as (
    select
      coalesce(ws.warehouse_sk, iv.warehouse_sk) as warehouse_sk,
      coalesce(ws.item_sk, iv.item_sk)           as item_sk,
      ws.year_number,
      ws.week_of_year,
      wr.week_start_date_sk as date_sk,
      wr.week_start_calendar_dt as calendar_dt,
      coalesce(ws.weekly_quantity, 0)       as weekly_quantity,
      coalesce(ws.weekly_sales_amt, 0)      as weekly_sales_amt,
      coalesce(ws.weekly_net_profit, 0)     as weekly_net_profit,
      coalesce(ws.weekly_avg_quantity, 0)   as weekly_avg_quantity,
      coalesce(iv.sum_weekly_inv_qty, 0)    as sum_weekly_inv_qty,
      coalesce(iv.avg_daily_inv_qty, 0)     as avg_daily_inv_qty
    from weekly_sales ws
    left join weekly_inventory iv
     on ws.warehouse_sk = iv.warehouse_sk
     and ws.item_sk      = iv.item_sk
     and ws.year_number  = iv.year_number
     and ws.week_of_year = iv.week_of_year
    INNER JOIN week_reference_date wr -- <-- inner join ensures only weeks with a Sunday
      on COALESCE(ws.year_number, iv.year_number) = wr.year_number
     and COALESCE(ws.week_of_year, iv.week_of_year) = wr.week_of_year
)

-- 5) Final aggregation: single row per key
select
    warehouse_sk,
    item_sk,
    date_sk,
    calendar_dt,
    year_number,
    week_of_year,
    sum(weekly_quantity)       as sum_weekly_quantity,
    sum(weekly_sales_amt)      as sum_weekly_sales_amt,
    sum(weekly_net_profit)     as sum_weekly_net_profit,
    sum(weekly_avg_quantity)/7 as avg_qty_per_day,
    sum(sum_weekly_inv_qty)    as sum_weekly_inv_qty,
    sum(avg_daily_inv_qty)     as avg_daily_inv_qty,

    -- safe divide-by-zero ratios
     -- weeks of supply (inventory / weekly sales)
    case
      when sum(weekly_quantity) = 0 then null
      else (sum(sum_weekly_inv_qty) * 1.0) / nullif(sum(weekly_quantity), 0)
    end as wks_supply,

    -- low stock flag: true if less than 1 week supply
    case
      when sum(weekly_quantity) = 0 then false
      when (sum(sum_weekly_inv_qty) * 1.0) / nullif(sum(weekly_quantity),0) < 1 then true
      else false
    end as low_stock_flag_for_week

from sales_inv_union
WHERE 1=1
    {% if is_incremental() %}
        and calendar_dt >= '{{ MAX_CAL_DT }}'
    {% endif %}
group by
    warehouse_sk,
    item_sk,
    date_sk,
    calendar_dt,
    year_number,
    week_of_year
