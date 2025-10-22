{% macro generate_dim_calendar(start_date, end_date) %}
{% set start_dt = modules.datetime.datetime.strptime(start_date, "%Y-%m-%d") %}
{% set end_dt = modules.datetime.datetime.strptime(end_date, "%Y-%m-%d") %}
{% set num_days = (end_dt - start_dt).days + 1 %}

with date_spine as (
    select
        dateadd(day, seq4(), to_date('{{ start_date }}')) as date_day
    from table(generator(rowcount => {{ num_days }}))
)

select
    date_day as cal_dt,
    cast(to_char(date_day, 'YYYYMMDD') as integer) as date_sk,
    year(date_day) as year_number,
    month(date_day) as month_number,
    to_char(date_day, 'FMMonth') as month_name,
    quarter(date_day) as quarter_number,
    day(date_day) as day_of_month,
    dayofweek(date_day) as day_of_week_number,
    to_char(date_day, 'Day') as day_name,
    weekofyear(date_day) as week_of_year,
    last_day(date_day, 'month') as month_end_date,
    date_trunc('month', date_day) as month_start_date,
    date_trunc('quarter', date_day) as quarter_start_date,
    date_trunc('year', date_day) as year_start_date,
    case when dayofweek(date_day) in (1,7) then true else false end as is_weekend,
    case 
        when month(date_day) in (1,3,5,7,8,10,12) then 31
        when month(date_day) = 2 and mod(year(date_day),4)=0 and (mod(year(date_day),100)<>0 or mod(year(date_day),400)=0) then 29
        when month(date_day) = 2 then 28
        else 30 
    end as days_in_month,
    concat(year(date_day), '-', lpad(month(date_day), 2, '0')) as year_month_number,
    concat(year(date_day), lpad(weekofyear(date_day), 2, '0')) year_week_number,
    concat('Q', quarter(date_day), ' ', year(date_day)) as quarter_label
from date_spine
order by date_day

{% endmacro %}