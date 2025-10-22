SELECT * 
FROM {{ source('tpcds', 'date_dim') }}