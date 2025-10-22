{{ config(
    materialized='incremental',
    unique_key=['warehouse_sk', 'item_sk', 'date_sk'],
    incremental_strategy='insert_overwrite'
) }}

with all_sales 
as (
    (select * from {{ ref('stg_tpcds__catalog_sales') }})
    UNION ALL
    (select * from {{ ref('stg_tpcds__web_sales') }})
),
all_sales_aggregated as
(
SELECT
    warehouse_sk,
    item_sk,
    sold_date_sk,
    SUM(quantity) as daily_quantity,
    SUM(sales_amt) daily_sales_amt,
    SUM(net_profit) daily_net_profit
FROM all_sales
GROUP BY 1, 2, 3
),
all_sales_aggregated_with_week_no
AS
(
    SELECT
        a.warehouse_sk,
        a.item_sk,
        d.date_sk,
        d.year_number,
        d.week_of_year,
        daily_quantity,
        daily_sales_amt,
        daily_net_profit
    FROM all_sales_aggregated a 
        LEFT join {{ ref('dim_calendar')}} d ON d.date_natural_key = a.sold_date_sk
),
 -- doing this just as a second safety net
all_sales_aggregated_with_week_no_consolidated
AS
(
    SELECT 
        warehouse_sk,
        item_sk,
        date_sk,
        MAX(year_number) as year_number,
        MAX(week_of_year) as week_of_year,
        SUM(daily_quantity) as daily_quantity,
        SUM(daily_sales_amt) as daily_sales_amt,
        SUM(daily_net_profit) as daily_net_profit
    FROM
        all_sales_aggregated_with_week_no
    GROUP BY 1,2,3
)
SELECT 
    DISTINCT warehouse_sk,
    item_sk,
    date_sk,
    year_number,
    week_of_year,
    daily_quantity,
    daily_sales_amt,
    daily_net_profit
FROM
    all_sales_aggregated_with_week_no_consolidated



