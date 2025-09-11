-- Step 1
-- Tasks to perform for Retial ETL project
SHOW USERS;

-- create new user named wcd_midterm_load_user 
CREATE OR REPLACE USER wcd_midterm_load_user password="wcdmidtermloaduser1234";

-- granting account admin rol
GRANT ROLE accountadmin to USER wcd_midterm_load_user;

-- drop user after lecture

-- Step 2
-- DATABASE & SCHEMA CREATION

CREATE OR REPLACE DATABASE TPCDS;

CREATE OR REPLACE SCHEMA RAW;

USE DATABASE TPCDS;
USE SCHEMA RAW;

-- Create Table
CREATE OR REPLACE TABLE tpcds.raw.inventory
(inv_date_sk INTEGER NOT NULL,
inv_item_sk INTEGER NOT NULL,
inv_quantity_on_hand INTEGER NOT NULL,
inv_warehouse_sk INTEGER NULL DEFAULT 0);

-- DROP TABLE tpcds.raw.inventory;
-- if you want to set the default value for a coulmn to zero
-- ALTER TABLE tpcds.raw.inventory 
-- ALTER COLUMN inv_quantity_on_hand SET DEFAULT 0;

-- EDA
DESCRIBE TABLE tpcds.raw.inventory;

SELECT COUNT(*) FROM tpcds.raw.inventory;

SELECT *
FROM tpcds.raw.inventory
WHERE inv_date_sk = 2452451 AND inv_item_sk = 17683
LIMIT 100;

SELECT COUNT(*)
FROM tpcds.raw.inventory
WHERE inv_warehouse_sk IS NULL;

-- Code to perform clening
LIST @inventory_stage;
REMOVE @inventory_stage;
SHOW STAGES;
DROP STAGE inventory_stage;
SHOW STAGES;

-- TESTING
USE tpcds.raw;
SHOW TABLES;
SELECT COUNT(*) FROM tpcds.raw.catalog_sales;
SELECT COUNT(*) FROM tpcds.raw.call_center;

SHOW STAGES;
LIST @~;

-- Viewing file formats
USE DATABASE TPCDS;
USE SCHEMA RAW;
SHOW FILE FORMATS;
DESCRIBE FILE FORMAT tpcds.raw.comma_csv;
