{% snapshot int_snapshot__dim_customer %}

{{ config(
    target_schema='snapshots',
    unique_key='c_customer_sk',
    strategy='check', 
    check_cols='all'
) }}

SELECT *
FROM {{ ref('stg_tpcds__customer') }}
ORDER BY c_customer_sk

{% endsnapshot %}
