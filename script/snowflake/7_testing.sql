-----------------------------------------------------------------
-- TESTING
-----------------------------------------------------------------
-- Contains examples of tests that can be run on different tables.
-- Customer Dimension

---- customer_id is not null
select count(*) = 0 from SF_TPCDS.ANALYTICS.dim_customer
where c_customer_sk is null;

-- Weekly Sales Inventory

-- warehouse_sk, item_sk and sold_wk_sk is unique
select count(*) = 0 from 
    (select 
        warehouse_sk, item_sk, sold_wk_sk 
    from SF_TPCDS.ANALYTICS.fact_WEEKLY_SALES_INVENTORY 
    group by 1,2,3 
    having count(*) > 1);

-- Relationship Test
select count(*) = 0 from 
    (select 
        dim.I_ITEM_SK 
    from SF_TPCDS.ANALYTICS.fact_WEEKLY_SALES_INVENTORY fact 
    left join SF_TPCDS.RAW.ITEM dim 
    on dim.i_item_sk=fact.item_sk
    WHERE dim.i_item_sk is null);


-- Adhoc Testing 
select count(*) = 0 from 
(select C_CURRENT_CDEMO_SK, cd.cd_demo_sk
from SF_TPCDS.RAW.customer c
left join SF_TPCDS.RAW.customer_demographics cd
on c.C_CURRENT_CDEMO_SK = cd.cd_demo_sk
where  C_CURRENT_CDEMO_SK is not null and cd.cd_demo_sk is null)
;