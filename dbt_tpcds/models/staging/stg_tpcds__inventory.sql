SELECT 
    INV_DATE_SK, 
    INV_ITEM_SK, 
    INV_QUANTITY_ON_HAND, 
    INV_WAREHOUSE_SK
FROM {{ source('tpcds', 'inventory') }}