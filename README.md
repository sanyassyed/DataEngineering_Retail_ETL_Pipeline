# Analytical Data Engineering Project

## 📌 Project Overview

This project demonstrates a **cloud-based Analytical Data Engineering pipeline**. Data is ingested from multiple sources, transformed within **Snowflake**, and prepared for **business intelligence (BI)** usage. The BI tool **Metabase** connects to Snowflake to generate dashboards and reports for insights into retail sales and inventory.

### 🔹 Project Diagram

![Project_Archictecture](./docs/AE_diagram.png)

---

## 📊 About the Data

### 2.1 Data Background

The dataset is derived from **TPCDS**, a well-known benchmarking dataset focused on **Retail Sales**. It includes:

* **Sales records** from websites and catalogs.
* **Inventory levels** for each item across warehouses.

Data sources are divided into two parts:

* **AWS RDS (Postgres DB)**

  * Contains all tables except inventory.
  * Tables are refreshed **daily**, requiring a daily ETL pipeline.

* **AWS S3 (Inventory Data)**

  * Contains the **inventory.csv** file.
  * A new file is dumped **daily** but typically records data **weekly** (end of week per item per warehouse).

### 2.2 Tables in the Dataset

Schemas and table definitions can be reviewed directly in **Snowflake**.

* Customer-related tables are **horizontally correlated**, making them suitable for integration into a single **Customer Dimension** during ETL.

*(Insert schema diagram here if available)*

---

## 🏢 Business Requirements

### 3.1 Snowflake Data Warehouse Requirements

New tables and transformations must be created in Snowflake to enable BI analysis:

* **Integration:** Combine raw customer-related tables into a single dimension table.
* **Fact Table Creation:** Includes the following calculated metrics:

  * `sum_qty_wk` → Total sales quantity per week.
  * `sum_amt_wk` → Total sales amount per week.
  * `sum_profit_wk` → Total net profit per week.
  * `avg_qty_dy` → Average daily sales quantity (`sum_qty_wk / 7`).
  * `inv_on_hand_qty_wk` → Item inventory at the end of each week across warehouses.
  * `wks_sply` → Weeks of supply (`inv_on_hand_qty_wk / sum_qty_wk`).
  * `low_stock_flg_wk` → Boolean flag for low stock conditions:

    * Set to **True** if on any day `avg_qty_dy > 0` and `avg_qty_dy > inv_on_hand_qty_wk`.

### 3.2 Metabase Requirements

Dashboards and reports in **Metabase** should provide:

* Identification of **highest and lowest-performing items** each week (by sales amount and quantity).
* Display of **items with low supply levels** per week.
* Detection of **low-stock items**, showing week and warehouse, flagged as `"True"`.

---

## ☁️ Project Infrastructure

This project is built entirely on the **AWS Cloud**:

* **Servers:** Multiple AWS servers provisioned.
* **Tools:**

  * **Airbyte** → Data ingestion.
  * **DBT** → Data transformation.
  * **Metabase** → BI dashboards.
* **Data Warehouse:** **Snowflake** for storage and transformations.
* **AWS Lambda:** Serverless function for ingestion from **S3**.

---

## ⚙️ Part One: Data Ingestion

### 🔹 Data Ingestion Diagram

*(Insert ingestion diagram here)*

* **From AWS RDS (Postgres):**

  * Use **Airbyte** to extract tables from schema `raw_st` and load them into Snowflake.

* **From AWS S3 (Inventory):**

  * Use an **AWS Lambda** function to fetch `inventory.csv` and load it into Snowflake.

---

## 🔄 Part Two: Data Transformation

### 🔹 Data Transformation Diagram

*(Insert transformation diagram here)*

* Transform raw tables into business-ready models within **Snowflake**.
* Build the **data model** using **DBT**.
* Schedule transformations and maintain lineage with DBT.

---

## 📈 Part Three: Data Analysis

### 🔹 Data Analysis Diagram

*(Insert analysis diagram here)*

* Connect **Snowflake** to **Metabase**.
* Build dashboards and reports to fulfill business requirements.
* Deliver insights on sales performance, inventory health, and supply chain monitoring.

---

## 🚀 Tech Stack

* **Cloud Platform:** AWS
* **Data Warehouse:** Snowflake
* **Data Ingestion:** Airbyte, AWS Lambda
* **Transformation:** DBT
* **Visualization / BI:** Metabase

---

## 📌 Next Steps

* [ ] Add ER diagrams and data models.
* [ ] Include screenshots of Metabase dashboards.
* [ ] Automate CI/CD for DBT and Airbyte pipelines.

---

Would you like me to make this **README more visually engaging** with badges (e.g., Snowflake, AWS, DBT, Metabase logos) and a **table of contents**, so it looks like a polished open-source project on GitHub?
