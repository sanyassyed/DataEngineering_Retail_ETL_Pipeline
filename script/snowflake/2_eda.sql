--------------------------------------
-- EDA
--------------------------------------
-- Source Week 7 Lecture 1

-- After Performing EL using Lambda (data extracted from s3) & Airbyte (data extracted from RDS)
-- We have data in TPCDS.RAW schema tables
-- We will now do EDA on this raw data to understand the dataset by exploring it
USE DATABASE TPCDS;
USE SCHEMA raw;

-- call_center
SELECT * FROM raw.call_center
LIMIT 5;

SELECT COUNT(*) total_records
FROM raw.call_center; --3

-- catalog_page
SELECT * 
FROM raw.catalog_page
LIMIT 5;

SELECT COUNT(*) total_records
FROM raw.catalog_page; --11718

-- catalog_sales
SELECT * 
FROM raw.catalog_sales
LIMIT 5;

SELECT COUNT(*) total_records
FROM raw.catalog_sales; --1225866

-- customer
SELECT * 
FROM raw.customer
LIMIT 5;

SELECT COUNT(*) total_records
FROM raw.customer; --100000

-- customer_address
SELECT * 
FROM raw.customer_address
LIMIT 5;

SELECT COUNT(*) total_records
FROM raw.customer_address; --50000

-- customer_demographics
SELECT * 
FROM raw.customer_demographics
LIMIT 5;

SELECT COUNT(*) total_records
FROM raw.customer_demographics; --480200

-- household_demographics
SELECT * 
FROM raw.household_demographics
LIMIT 5;

SELECT COUNT(*) total_records
FROM raw.household_demographics; --7200

-- income_band
SELECT * 
FROM raw.income_band
LIMIT 5;

SELECT COUNT(*) total_records
FROM raw.income_band; --20

-- inventory
SELECT * 
FROM raw.inventory
LIMIT 5;

SELECT COUNT(*) total_records
FROM raw.inventory; --10710000

SELECT COUNT(DISTINCT inv_item_sk) distinct_items
FROM raw.inventory; --9000

-- item
SELECT * 
FROM raw.item
LIMIT 5;

SELECT COUNT(*) total_records
FROM raw.item; --10710000

SELECT COUNT(DISTINCT i_item_sk)
FROM raw.item; --18000

-- promotion
SELECT * 
FROM raw.promotion
LIMIT 5;

SELECT COUNT(*) total_records
FROM raw.promotion; --300

-- ship mode
SELECT COUNT(*) total_records
FROM raw.ship_mode; --20

-- warehouse
SELECT COUNT(*) total_records
FROM raw.warehouse; --5

-- web_page
SELECT * 
FROM raw.web_page
LIMIT 5;

SELECT COUNT(*) total_records
FROM raw.web_page; --60

SELECT COUNT(DISTINCT wp_customer_sk) total_records
FROM raw.web_page; --17

-- web_sales
SELECT COUNT(*) total_records
FROM raw.web_sales; --615283


-- web_site
SELECT COUNT(*) total_records
FROM raw.web_site; --30


-- date_dim
SELECT *
FROM raw.date_dim
LIMIT 5;
--------------------------------
-- QUESTIONS & ANSWERS
--------------------------------
-- 1. The earliest and latest date of the sales and inventory (you need to join date_dim to see the exact date instead of date id)
SELECT MIN(d.cal_dt) earliest_date,
       MAX(d.cal_dt) latest_date
FROM raw.catalog_sales c
INNER JOIN raw.date_dim d
ON c.CS_SOLD_DATE_SK = d.d_date_sk; -- 2021-01-01 2025-06-26

SELECT MIN(d.cal_dt) earliest_date,
       MAX(d.cal_dt) latest_date
FROM raw.catalog_sales c
INNER JOIN raw.date_dim d
ON c.CS_SHIP_DATE_SK = d.d_date_sk; -- 2021-01-03 2025-09-24

SELECT MIN(d.cal_dt) earliest_date,
       MAX(d.cal_dt) latest_date
FROM raw.inventory i
INNER JOIN raw.date_dim d
ON i.inv_date_sk = d.d_date_sk; -- 2021-01-01 2025-06-25

-- 2. Row numbers of each table
-- Check above

-- 3. Pick one item to know how frequently it is ordered by customers and how frequently it is recorded in the inventory
-- Looking at the item with the most stock in the inventory
SELECT inv_item_sk,
       COUNT(*) total_records,
       SUM(inv_quantity_on_hand) total_in_stock
FROM raw.inventory
GROUP BY inv_item_sk
ORDER BY 3 DESC; -- inv_item_sk = 6208 & 1190 records

-- looking at the most orderdered item
-- Web sales
SELECT ws_item_sk,
       COUNT(*)
FROM raw.web_sales
GROUP BY ws_item_sk
ORDER BY COUNT(*) DESC
LIMIT 5; -- item_sk = 16339 Total_web_sales = 103

-- Analysing the item details in depth
SELECT *
FROM raw.web_sales
WHERE ws_item_sk = 16339;

-- Checking if all sales are unique or not
SELECT COUNT(DISTINCT WS_ORDER_NUMBER)
FROM raw.web_sales
WHERE ws_item_sk = 16339; -- 103

-- Catalog sales
SELECT CS_ITEM_SK,
       COUNT(*) total_sales
FROM raw.catalog_sales
GROUP BY cs_item_sk
ORDER BY COUNT(*) DESC
LIMIT 5; -- item_sk = 12523 Total_web_sales = 178

-- Checking if all sales are unique or not
SELECT COUNT(DISTINCT CS_ORDER_NUMBER)
FROM raw.catalog_sales
WHERE cs_item_sk = 12523; -- 178

-- How are the sales of these items on the opposite platforms
SELECT COUNT(*)
FROM raw.catalog_sales
WHERE cs_item_sk = 16339; -- 142

SELECT COUNT(*)
FROM raw.web_sales
WHERE ws_item_sk = 12523; -- 80

-- OBSERVATION: Both items are available on both platforms but are popular only on one platform
-- Looking at the above items by year
-- Catalog sales
SELECT EXTRACT(YEAR FROM d.cal_dt) year,
       COUNT(*)
FROM raw.catalog_sales c,
     raw.date_dim d
WHERE c.cs_sold_date_sk = d.d_date_sk AND c.cs_item_sk = 16339
GROUP BY 1
ORDER BY 1 ASC; -- 2021 - 32, 2022 - 29, 2023 - 25, 2024 - 45, 2025 -11

SELECT EXTRACT(YEAR FROM d.cal_dt) year,
       COUNT(*)
FROM raw.catalog_sales c,
     raw.date_dim d
WHERE c.cs_sold_date_sk = d.d_date_sk AND c.cs_item_sk = 12523
GROUP BY 1
ORDER BY 1 ASC; -- 2021 - 41, 2022 - 43, 2023 - 35, 2024 - 48, 2025 -11

-- OBSERVATION : In the year 2024 the top item of web sales had almost the same sales on catalog

SELECT EXTRACT(YEAR FROM d.cal_dt) year,
       COUNT(*)
FROM raw.web_sales c,
     raw.date_dim d
WHERE c.ws_sold_date_sk = d.d_date_sk AND c.ws_item_sk = 16339
GROUP BY 1
ORDER BY 1 ASC; -- 2021 - 22, 2022 - 25, 2023 - 25, 2024 - 24, 2025 -7

SELECT EXTRACT(YEAR FROM d.cal_dt) year,
       COUNT(*)
FROM raw.web_sales c,
     raw.date_dim d
WHERE c.ws_sold_date_sk = d.d_date_sk AND c.ws_item_sk = 12523
GROUP BY 1
ORDER BY 1 ASC; -- 2021 - 16, 2022 - 23, 2023 - 13, 2024 - 24, 2025 -4

-- OBSERVATION : In the year 2024 the top item of catalog sales had almost the same sales on web

SELECT * FROM DATE_DIM LIMIT 5;

-- 4. How many individual items
-- Computed above 18000

-- 5. How many individual customers
SELECT COUNT(DISTINCT c_customer_id) total_customers
FROM raw.customer; -- 100000

------------------------------------------------------
-- Analysing tables to understand business requirements
-------------------------------------------------------
-- web_sales
SELECT * FROM raw.web_sales LIMIT 5;

-- BUSINESS REQUIREMENTS
-- Documenting the dimensions needed to answer the questions in the business requirements
-- 1. sum_qty_wk: the sum sales_quantity of this week
-- CATALOG SALES
-- cols: catalog_sales.cs_quantity, catalog_sales.cs_sold_date, catalog_sales.cs_item_sk (so we know total quantity by item), date_dim.wk_num, item.i_iem_sk 
-- SUM(catalog_sales.cs_quantity) GROUP BY date_dim.wk_num, catalog_sales.cs_item_sk
-- dim tables from: date_dim, item
-- fact tables from: catalog_sales
-- WEB SALES
-- cols: web_sales.ws_quantity, web_sales.ws_sold_date, web_sales.ws_item_sk (so we know total quantity by item), date_dim.wk_num, item.i_iem_sk 
-- SUM(web_sales.ws_quantity) GROUP BY date_dim.wk_num, web.ws_item_sk
-- dim tables from: date_dim, item
-- fact tables from: web_sales

-- 2. sum_amt_wk: the sum sales_amount of this week
-- CATALOG SALES
-- cols: catalog_sales.cs_sales_price, catalog_sales.cs_quantity, catalog_sales.cs_sold_date, catalog_sales.cs_item_sk (so we know total quantity by item), date_dim.wk_num, item.i_iem_sk 
-- SUM(catalog_sales.cs_sales_price * catalog_sales.cs_quantity) GROUP BY date_dim.wk_num, catalog_sales.cs_item_sk
-- dim tables from: date_dim, item
-- fact tables from: catalog_sales
-- WEB SALES
-- cols: web_sales.ws_sales_price, web_sales.ws_quantity, web_sales.ws_sold_date, web_sales.ws_item_sk (so we know total quantity by item), date_dim.wk_num, item.i_iem_sk 
-- SUM(web_sales.ws_sales_price * web_sales.ws_quantity) GROUP BY date_dim.wk_num, web_sales.cs_item_sk
-- dim tables from: date_dim, item
-- fact tables from: web_sales

-- 3. sum_profit_wk: the sum net_profit of this week
-- CATALOG SALES
-- cols: catalog_sales.cs_net_profit, catalog_sales.cs_sold_date, catalog_sales.cs_item_sk (so we know total quantity by item), date_dim.wk_num, item.i_iem_sk 
-- SUM(catalog_sales.cs_net_profit) GROUP BY date_dim.wk_num, catalog_sales.cs_item_sk
-- dim tables from: date_dim, item
-- fact tables from: catalog_sales
-- WEB SALES
-- cols: web_sales.ws_net_profit, web_sales.ws_sold_date, web_sales.ws_item_sk (so we know total quantity by item), date_dim.wk_num, item.i_iem_sk 
-- SUM(web_sales.ws_net_profit) GROUP BY date_dim.wk_num, web_sales.cs_item_sk
-- dim tables from: date_dim, item
-- fact tables from: web_sales

-- 4. avg_qty_dy: the average daily sales_quantity of this week (= sum_qty_wk/7)
-- CATALOG SALES
-- cols: catalog_sales.cs_quantity, catalog_sales.cs_sold_date, catalog_sales.cs_item_sk (so we know total quantity by item), date_dim.wk_num, item.i_iem_sk 
-- SUM(catalog_sales.cs_quantity)/7 GROUP BY date_dim.wk_num, catalog_sales.cs_item_sk
-- dim tables from: date_dim, item
-- fact tables from: catalog_sales
-- WEB SALES
-- cols: web_sales.ws_quantity, web_sales.ws_sold_date, web_sales.ws_item_sk (so we know total quantity by item), date_dim.wk_num, item.i_iem_sk 
-- SUM(web_sales.ws_quantity)/7 GROUP BY date_dim.wk_num, web.ws_item_sk
-- dim tables from: date_dim, item
-- fact tables from: web_sales

-- 5. inv_on_hand_qty_wk: the item’s inventory on hand at the end of each week in all warehouses (=The inventory on hand of of this weekend)
-- INVENTORY
-- cols: inventory.inv_quantity_on_hand, inventory.inv_date_sk, inventory.inv_warehouse_sk
-- SUM(inventory.inv_quantity_on_hand) GROUP BY date_dim.wk_num, inventory.inv_warehouse_sk
-- dim tables from: date_dim, warehouse
-- fact tables from: inventory


-- 6. wks_sply: Weeks of supply, an estimate metrics to see how many weeks the inventory can supply the sales (inv_on_hand_qty_wk/sum_qty_wk)
-- INVENTORY
-- cols: date_dim.wk_num, catalog_sale.cs_quantity, web_sales.ws_quantity, catalog_sales.cs_item_sk, web_sales.ws_item_sk, inventory.inv_item_sk, inventory.INV_QUANTITY_ON_HAND
-- inventory.inv_quantity_on_hand at the end of the week/(SUM(catalog_sale.cs_quantity)+ SUM(web_sale.ws_quantity)) GROUP BY date_dim.wk_num, inventory.inv_item_sk
-- dim tables from: date_dim
-- fact tables from: inventory, catalog_sales, web_sales

-- 7. low_stock_flg_wk: Low stock weekly flag. During the week, if there is a single day, if [(avg_qty_dy > 0 && ((avg_qty_dy) > (inventory_on_hand_qty_wk)), then this week, the flag is True. avg_qty_dy: the average daily sales_quantity of this week (= sum_qty_wk/7)
-- cols: date_dim.wk_num, catalog_sale.cs_quantity, web_sales.ws_quantity, catalog_sales.cs_item_sk, web_sales.ws_item_sk, inventory.inv_item_sk, inventory.INV_QUANTITY_ON_HAND
-- low_stock_flag_week = ((SUM(catalog_sales.cs_quantity) + SUM(web_sales.ws_quatity)) > 0 && (SUM(catalog_sales.cs_quantity) + SUM(web_sales.ws_quatity)) ) > inventory.inv_quantity_on_hand THEN True GROUP BY date_dim.d_cal_dt and item and MAX(low_stock_flag_week)
-- dim tables from: date_dim
-- fact tables from: inventory, catalog_sales, web_sales
-- daily_sales = SUM(cs_quantity) + SUM(ws_quantity) 
-- GROUP BY item_sk, d_cal_dt
-- Join inventory (day-level):

-- sql
-- Copy code
-- daily_flag_day = CASE 
--                      WHEN daily_sales > 0 AND daily_sales > inv_quantity_on_hand
--                      THEN 1 ELSE 0 
--                  END
-- Roll up to weekly flag

-- sql
-- Copy code
-- low_stock_flg_wk = MAX(daily_flag_day)  -- per item, per week
-- GROUP BY item_sk, wk_num

--------------------------------------
-- DIMENSION TABLES
---------------------------------------
-- What tables to choose as dimensions
-- date_dim, warehouse, item

-- What columns to choose for those dimentions from the DB tables

-- DW Dimension: dim_customer
-- DB Tables: customer, customer_demographics, household_demographics, income_band
-- Columns to Choose: _AIRBYTE_RAW_ID, _AIRBYTE_EXTRACTED_AT, _AIRBYTE_META, _AIRBYTE_GENERATION_ID, C_LOGIN, C_BIRTH_DAY, C_LAST_NAME, C_BIRTH_YEAR, C_FIRST_NAME, C_SALUTATION, C_BIRTH_MONTH, C_CUSTOMER_ID, C_CUSTOMER_SK, C_BIRTH_COUNTRY, C_EMAIL_ADDRESS, C_CURRENT_ADDR_SK, C_CURRENT_CDEMO_SK, C_CURRENT_HDEMO_SK, C_FIRST_SALES_DATE_SK, C_LAST_REVIEW_DATE_SK, C_PREFERRED_CUST_FLAG, C_FIRST_SHIPTO_DATE_SK
