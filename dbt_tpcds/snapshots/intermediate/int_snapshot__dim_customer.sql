{% snapshot int_snapshot__dim_customer %}
{{ config(
    target_schema='snapshots',
    unique_key='c_customer_sk',
    strategy='check',
    check_cols=['c_first_name','c_last_name','c_email_address','c_current_addr_sk']
) }}
select 
* 
from {{ ref('stg_tpcds__customer') }}
{% endsnapshot %}

