SELECT 
    cs_sold_date_sk as sold_date_sk, 
    CS_WAREHOUSE_SK as warehouse_sk,
    cs_bill_customer_sk as bill_customer_sk,
    cs_item_sk as item_sk,
    cs_quantity as quantity,
    cs_sales_price as sales_price,
    cs_quantity * cs_sales_price as sales_amt,
    cs_net_profit as net_profit
FROM {{ source('tpcds', 'catalog_sales')}}
WHERE cs_quantity IS NOT NULL and 
      cs_quantity * cs_sales_price IS NOT NULL and
      CS_WAREHOUSE_SK IS NOT NULL