{% macro generate_dim_calendar(start_date, end_date) -%}
{%- set start_dt = modules.datetime.datetime.strptime(start_date, "%Y-%m-%d") -%}
{%- set end_dt   = modules.datetime.datetime.strptime(end_date,   "%Y-%m-%d") -%}
{%- set num_days = (end_dt - start_dt).days + 1 -%}

with date_spine as (
  select
    dateadd(day, seq4(), to_date('{{ start_date }}')) as date_day
  from table(generator(rowcount => {{ num_days }}))
)

select
  /* canonical date */
  date_day as calendar_dt,

  /* basic numeric fields */
  year(date_day)       as year_number,
  month(date_day)      as month_number,
  day(date_day)        as day_of_month,

  /* deterministic month name (avoids TO_CHAR token weirdness) */
  case month(date_day)
    when 1 then 'January'   when 2 then 'February' when 3 then 'March'
    when 4 then 'April'     when 5 then 'May'      when 6 then 'June'
    when 7 then 'July'      when 8 then 'August'   when 9 then 'September'
    when 10 then 'October'  when 11 then 'November' when 12 then 'December'
  end as month_name,

  /* Snowflake: DAYOFWEEK() => 0 = Sunday ... 6 = Saturday */
  dayofweek(date_day) as day_of_week_number,

  /* deterministic day name */
  case dayofweek(date_day)
    when 0 then 'Sunday'    when 1 then 'Monday'   when 2 then 'Tuesday'
    when 3 then 'Wednesday' when 4 then 'Thursday' when 5 then 'Friday'
    when 6 then 'Saturday'
  end as day_name,

  /* ISO week/year for consistent weekly buckets */
  weekiso(date_day) as week_of_year,
  yearofweekiso(date_day) as iso_year,

  /* month/quarter/year boundaries */
  last_day(date_day, 'month')   as month_end_date,
  date_trunc('month', date_day) as month_start_date,
  date_trunc('quarter', date_day) as quarter_start_date,
  date_trunc('year', date_day)  as year_start_date,

  /* is weekend (0=Sun,6=Sat) */
  case when dayofweek(date_day) in (0,6) then true else false end as is_weekend,

  /* days in month */
  case
    when month(date_day) in (1,3,5,7,8,10,12) then 31
    when month(date_day) = 2 and mod(year(date_day),4)=0 and (mod(year(date_day),100)<>0 or mod(year(date_day),400)=0) then 29
    when month(date_day) = 2 then 28
    else 30
  end as days_in_month,

  /* helpful labels */
  concat(year(date_day), '-', lpad(month(date_day), 2, '0')) as year_month_number,
  concat(yearofweekiso(date_day), lpad(weekiso(date_day), 2, '0')) as year_week_number,
  concat('Q', quarter(date_day), ' ', year(date_day)) as quarter_label,
  quarter(date_day) as quarter_number

from date_spine
order by date_day
{%- endmacro %}

