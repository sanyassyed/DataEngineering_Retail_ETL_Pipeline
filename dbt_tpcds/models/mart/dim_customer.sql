with base as (
    select *,
           row_number() over (partition by customer_natural_key, cast(start_date as date) order by start_date) as seq
    from {{ ref('int__dim_customer') }}
    where active_status = true
)
select {{ dbt_utils.generate_surrogate_key(['customer_natural_key', 'CAST(start_date AS DATE)', 'seq']) }} as customer_surrogate_key,
       *
from base
