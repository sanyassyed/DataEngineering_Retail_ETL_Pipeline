with customer_snap as (
    select 
        c_customer_sk,
        c_first_name,
        c_last_name,
        c_birth_country,
        c_login,
        c_email_address,
        c_current_cdemo_sk,
        c_current_addr_sk,
        c_first_shipto_date_sk,
        c_last_review_date_sk,
        dbt_valid_from as start_date,
        dbt_valid_to as deactivate_date,
        iff(dbt_valid_to is null, true, false) as active_status
    from {{ ref('int_snapshot__dim_customer') }}
),

customer_address as (
    select * from {{ source('tpcds', 'customer_address') }}
),

customer_demographics as (
    select * from {{ source('tpcds', 'customer_demographics') }}
),

household_demographics as (
    select * from {{ source('tpcds', 'household_demographics') }}
),

income_band as (
    select * from {{ source('tpcds', 'income_band') }}
)

select
    cs.c_customer_sk as customer_natural_key,
    cs.c_first_name as first_name,
    cs.c_last_name as last_name,
    cs.c_birth_country as birth_country,
    cs.c_login as login,
    cs.c_email_address as email_address,
    ca.ca_city as city,
    ca.ca_state as state,
    ca.ca_country as country,
    cd.cd_gender as gender,
    cd.cd_education_status as education_status,
    cd.cd_marital_status as marital_status,
    cd.cd_purchase_estimate as purchase_estimate,
    hd.hd_buy_potential as buy_potential,
    ib.ib_upper_bound as upper_bound,
    cs.start_date as start_date,
    cs.deactivate_date as deactivate_date,
    cs.active_status as active_status
from customer_snap cs
left join customer_address ca on cs.c_current_addr_sk = ca.ca_address_sk
left join customer_demographics cd on cs.c_current_cdemo_sk = cd.cd_demo_sk
left join household_demographics hd on cd.cd_demo_sk = hd.hd_demo_sk
left join income_band ib on hd.hd_income_band_sk = ib.ib_income_band_sk
