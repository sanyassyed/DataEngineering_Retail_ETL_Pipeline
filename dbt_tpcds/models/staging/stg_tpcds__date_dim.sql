SELECT
     cal_dt,
     d_date_sk 
FROM {{ source('tpcds', 'date_dim') }}