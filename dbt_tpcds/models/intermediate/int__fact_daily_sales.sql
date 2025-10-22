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
    {% set MAX_CAL_DT = run_query(MAX_CAL_DATE_query).columns[0][0] %}
  {% endif %}

{% endif %}

-- 1) Combine all sales sources
with all_sales 
as (
    (select * from {{ ref('stg_tpcds__catalog_sales') }})
    UNION ALL
    (select * from {{ ref('stg_tpcds__web_sales') }})
),

-- 2) Aggregate daily totals
all_sales_aggregated as
(
SELECT
    warehouse_sk,
    item_sk,
    sold_date_sk,
    SUM(quantity) as daily_quantity,
    SUM(sales_amt) as daily_sales_amt,
    SUM(net_profit) as daily_net_profit
FROM all_sales
GROUP BY 1, 2, 3
),

-- 3) Map TPCDS date_sk to our dim_calendar
all_sales_aggregated_with_week_no
AS
(
    SELECT
        a.warehouse_sk,
        a.item_sk,
        d.date_sk,
        d.calendar_dt,
        d.year_number,
        d.week_of_year,
        daily_quantity,
        daily_sales_amt,
        daily_net_profit
    FROM all_sales_aggregated a
        LEFT JOIN {{ ref('int__date_bridge') }} b 
        ON b.d_date_sk = a.sold_date_sk
        LEFT JOIN {{ ref('dim_calendar')}} d 
        ON d.calendar_dt = b.cal_dt
),

-- 4) Defensive consolidation: single record per day/item/warehouse
all_sales_aggregated_with_week_no_consolidated
AS
(
    SELECT 
        warehouse_sk,
        item_sk,
        date_sk,
        calendar_dt,
        MAX(year_number) as year_number,
        MAX(week_of_year) as week_of_year,
        SUM(daily_quantity) as daily_quantity,
        SUM(daily_sales_amt) as daily_sales_amt,
        SUM(daily_net_profit) as daily_net_profit
    FROM
        all_sales_aggregated_with_week_no
    GROUP BY 1,2,3,4
)
-- doing this just as a second safety net
SELECT 
    DISTINCT warehouse_sk,
    item_sk,
    date_sk,
    calendar_dt,
    year_number,
    week_of_year,
    daily_quantity,
    daily_sales_amt,
    daily_net_profit,
    current_date() as UPDATE_TIME
FROM
    all_sales_aggregated_with_week_no_consolidated
where 1=1
    {% if is_incremental() %}
        and calendar_dt >= '{{ MAX_CAL_DT }}'
    {% endif %}


