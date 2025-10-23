SELECT 
    WS_SOLD_DATE_SK as sold_date_sk,
    WS_WAREHOUSE_SK as warehouse_sk,
    WS_BILL_CUSTOMER_SK as bill_customer_sk,
    WS_ITEM_SK as item_sk,
    WS_QUANTITY as quantity,
    WS_SALES_PRICE as sales_price, 
    WS_QUANTITY * WS_SALES_PRICE AS sales_amt,
    WS_NET_PROFIT as net_profit
FROM {{ source('tpcds', 'web_sales')}}
WHERE ws_quantity IS NOT NULL and 
      ws_quantity * ws_sales_price IS NOT NULL and
      WS_WAREHOUSE_SK IS NOT NULL