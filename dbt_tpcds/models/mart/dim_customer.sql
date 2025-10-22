select {{ dbt_utils.generate_surrogate_key(['customer_natural_key', 'start_date']) }} as customer_surrogate_key,
       *
from {{ ref('int__dim_customer') }}
where active_status = true
