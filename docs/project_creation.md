# Project Creation Steps
Notes are from Week 4 Lecture 2 - Airbyte, Lambda & Project Data Ingestion

## Tools & Setup Required
* `S3` 
    * USE: to get `inventory.csv` from the WeCloudData Bucket
* `Snowflake Console` 
    * CREATE
        * an account
        * Raw Database & Staging
        * Production Database
    * USE: To load data 
* `snowsql` - Snowflake CLI on `host EC2 instance (zara_de)`
    * INSTALLATION: Install via [Makefile](../../Makefile) in home directory of the `host EC2 instance (zara_de)` or Instructions in `Week 4 Lecture 1 Notes/Video`
    * USE: To manage snowflake from host machine via CLI
* `AWS Lambda`
    * USE: To pull data from S3 and load into snowflake on a schedule
* EC2 Instance with `dbt` [Note: we are using `host EC2 instance (zara_de)`]
    * INSTALLATION: Install `dbt-pg` via [Makefile](../setupfiles/Makefile_zara_de) in the home folder or Install via instructions in `Week 1 Lab EC2 and Linux`
    * USE: To transform the data in Snowflake
* Host EC2 (zara_de) with `psql` - 
    * INSTALLATION: Install via [Makefile](../setupfiles/Makefile_zara_de) in the home folder or Instructions in `Week 1 Lab EC2 and Linux`
    * USE: The psql will be used to connect to Postgres database if necessary.
* Host EC2 (zara_de) with `aws-cli` - 
    * INSTALLATION: Install via [Makefile](../setupfiles/Makefile_zara_de) in the home folder
    * USE:
        * The aws-cli will help us connect to aws via command line.
        * Eg: Create & Upload lambda layer
* `RDS Postgres`
    * USE: To pull another dataset provided by WeCloudData
* EC2 Instance with `Airbyte`
    * CREATE: 
        * Create t2.xlarge instance with 32GB Memory called `Airbyte` via instructions in `Week 1 Lab EC2 and Linux`
        * SSH port 22
        * TCP port 8000
        * `ssh Airbyte -L 8000:localhost:8000`
    * INSTALL: 
        * make
        ```bash
        sudo apt update
        sudo apt install make
        ```
        * `docker` & `docker-compose` via 
            * [Makefile](../setupfiles/Makefile_airbyte) `make install-docker`, `make install-compose` & `make post-install`
            * Follow instructions in `Week 2 Lab Install Airbyte and Metabase with Docker`
        * `Airbyte` via abctl
            * [Makefile](../setupfiles/Makefile_airbyte) `make install-abctl`, `make start-airbyte`, `make stop-airbyte` & `make restart-airbyte`
            * Get Login details using the command `abctl local credentials` ( first time user set username: s*****een@gmail.com organization:airbyte)
    * USE: To pull data from RDS into snowflake
* EC2 Instance with `Metabase`
    * CREATE: Create t2.small instance `Metabase` via instructions in `Week 1 Lab EC2 and Linux`
    * INSTALL: 
        * `docker` & `docker-compose` via 
            * Makefile (copy the applicable code & create a Makefile in the Airbyte instance) or
            * Follow instructions in `Week 2 Lab Install Airbyte and Metabase with Docker`
        * `Metabase` via docker
    * USE: To visualize the data pulled from snowflake

---

## Part 1 : s3 -> Lambda -> Snowflake

### Step 1 : Pre-requisite
* **Host Machine**: environment to build the lambda layer
    * conda
    * aws cli
    * snowsql
* **AWS Console**:
    * User eg: `guest` with the following custom policy eg:`S3ReadWriteExternal` to let the user read from and write to external account s3 buckets
    * Create the access key for the user and save the user key and secret to use in the lambda function later to be able to access the external s3 bucket witht the data i.e `inventory.csv`
    * optionally you can add the user `guest` to the user group `guest_group` to stay organised
    ```json
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "*"
        }
    ]
    }
    ```
### Step 2: Snowflake 
* Instructions in `Week 4 - Exercise 1-Snowflake` & `Week 4 - Lecture 2 - Airbyte, Lambda & Project Data Ingestion` Notes
* Use the warehouse - `compute_wh`
* In the snowflake console create the following:
    * Code can be viewed in the following worksheet on snowflake [Wk4_Lec2_Retail_Project worksheet](https://app.snowflake.com/ardimvt/jo76007/w45glwo1zhJK#query)
    * Database - `tpcds`
    * schema - `raw`
    * new user - `wcd_midterm_load_user` (give password too)
    * grant role- `accountadmin`
    * table - `inventory`
* Changes from the lecture:
    * Make sure when writing the table schema the `inv_warehouse_sk` table has `NULL` not `NOT NULL` as the column condition & `DEFAULT 0`
    * Remember the default value only applies when inserting into table and not when copying (like we do wiht the `COPY INTO` command when copying data from stage to table)

### Step 3: Lambda Function Creation
* Goto AWS console
* Create the lambda function
* Use `config.toml` to save the parameters for `snowflake`, `aws` & `s3`
* Use the `guest` user key & secret to access the s3 bucket via `REQUEST PAYER`
* Write the code to do the following
    * pull data file from url using requests
    * write the file locally to `/tmp` folder on lambda
    * create file format on snowflake - here give the additional attribute to handle nulls `NULL_IF = ('')`
    * create stage on snowflake
    * put file from `/tmp` to snowflake stage
    * list stage
    * copy data from stage to table
* Deploy and test the lambda functions to know which packages are missing in lambda that you need to add to the layer
* Add the required packagest to be added to the lambda layer along with the versions to the `requirements.txt` file on the host machine
* Create layer (to zip packages required by lambda)
    * Use an EC2 instance or cloud console to do that using the following code
    ```bash
    # goto a folder where you want to create - the virtual env & folder for storing the lambda layers lambda_layers
    # create a folder for the script
    mkdir script
    cd script
    mkdir -p lambda_layers/python/lib/python3.12/site-packages

    # create vitual env for lambda functions unsing the same python version as the lambda function
    conda create --prefix ./.venv python=3.12 pip -y
    # activate virtual env
    conda activate .venv

    # upgrade pip, setuptools and wheel
    pip install --upgrade pip setuptools wheel

    # install the packages into lambda_layers/python/lib/python3.12/site-packages using the virtual env python
    pip install -r requirements.txt --target lambda_layers/python/lib/python3.12/site-packages/. 

    # view the versions of the packages installed
    pip freeze --path lambda_layers/python/lib/python3.12/site-packages/

    # zip the packages for lambda i.e everything in the lambda_layers folder into a zip file named snowflake_lambda_layer.zip
    cd lambda_layers/
    zip -r snowflake_lambda_layer.zip *

    # publish layer so it is available on the aws console under lambda layers
    aws lambda publish-layer-version \
        --layer-name fl-snowflake-lambda-layer \
        --compatible-runtimes python3.12 \
        --zip-file fileb://snowflake_lambda_layer.zip
    ```
* Attach the created layer `fl-snowflake-lambda-layer` to the lambda function via the AWS Console 
    * Go down the page of the lambda function to the `Layer` section 
    * Select the `Add a Layer` button
    * Custom Layers
    * Select `fl-snowflake-lambda-layer`
    * Version: 1
* Increase the processing capacity of the lambda funciton as follows:
    * Goto the `Configuration` tab
    * Select `Edit`
    * Increase `memeory` to maximum `3008` is the free account limit otherwise increase to `10240`
    * Increase `Ephemeral Storage` to `10240`
    * `Timeout` to 15 mins
    * `Save`
* Test the lambda function:
* After the test in snowflake you will see the following:
    * File Format named `comma_csv`
    * Named Stage called `inventory_stage` with the `inventory.csv.gz`
    * Data loaded into the table `tpcds.raw.inventory` with `10710000` rows

### Step 4 : Scheduling using EventBridge Trigger
* We are going to set `EventBridge` in the Lambda function to make it run on every night 2 am EST (6 AM UTC).
* Select the trigger button
* From the drop down box select `EventBridge (CloudWatch Events)`
* Create a new rule named `trigger-2am-EST`
* Schedule expression write the following CRON schedule `cron(0 6 * * ? *)`
* Add
* **Now the lambda function is able to pull data from the s3 bucket and load it into snowflake every day at 2 am EST**

### Codes:
* Lambda Function [lambda_funtion](../script/lambda_function.py)
* Config file [config.toml](../script/config.toml)
* Requirements File [requirements.txt](../script/requirements.txt)
* Snowflake Worksheet [Wk4_Lec2_Retail_Project worksheet]()

---

## Part 2: RDS Postgres -> Airbyte -> Snowflake
### Tools
* Host EC2 instance (zara_de)
* Airbyte in `Airbyte` EC2 t2.xlarge instance with 16GB memory

### Step 1: Setup & Start Airbyte
* Start Airbyte using the command `abctl local start`
* Follow the steps in the `Wk 4 [Workshop] Airbyte`
* Create Source - Postgres
* Create Destination - Snowflake
* Create Connection
* Sync Now - The data is now loaded from source to destination and this load happens every day at 2 am
* NOTE: 
    * For `Security` `SSL Modes` select `allow`
    * In connections for cron give `0 0 6 * * ?`
* ERRORS:
    * `502 ERROR`: If you get `502` error follow the below steps [resource](https://github.com/airbytehq/airbyte/issues/65567)
    ```bash
    # Had to also set the token by hand like this - this is in parts lifted from the slack channel

    docker ps

    # Find your container id

    docker exec -it <containerID> bash

    # Now inside the container do this

    # Check current status
    kubectl -n airbyte-abctl get pods

    # Generate and apply matching auth tokens to both services
    BEARER_TOKEN=$(openssl rand -hex 16)
    echo "Generated token: $BEARER_TOKEN"

    kubectl -n airbyte-abctl set env deployment/airbyte-abctl-worker \
    WORKLOAD_API_BEARER_TOKEN="$BEARER_TOKEN" \
    INTERNAL_API_AUTH_TOKEN="$BEARER_TOKEN"

    kubectl -n airbyte-abctl set env deployment/airbyte-abctl-workload-api-server \
    WORKLOAD_API_BEARER_TOKEN="$BEARER_TOKEN"

    # Restart both services
    kubectl -n airbyte-abctl rollout restart deployment airbyte-abctl-worker
    kubectl -n airbyte-abctl rollout restart deployment airbyte-abctl-workload-api-server

    # Wait for rollouts to complete
    kubectl -n airbyte-abctl rollout status deployment airbyte-abctl-worker
    kubectl -n airbyte-abctl rollout status deployment airbyte-abctl-workload-api-server
    ```
    * `PG DATA ERROR`: If you get `ERROR failed to determine if any previous psql version exists: error reading pgdata version file: open /home/ubuntu/.airbyte/abctl/data/airbyte-volume-db/pgdata/PG_VERSION: permission denied` error run the following command on the Airbyte instance 
        * `sudo chown -R ubuntu:ubuntu /home/ubuntu/.airbyte`
        * Check if the owner of the following directories is ubuntu `ls -ld /home/ubuntu/.airbyte` and `ls -ld /home/ubuntu/.airbyte/abctl/data/airbyte-volume-db/pgdata`
    * AIRBYTE CONNECTION ERROR - Primary Key Missing - Select `SYNC Mode` as `Full Refresh | Overwrite`

---

## Improvements
* Create lambda function via AWS CLI rather than the AWS Console


## Resources:
* Course Github for project [here](https://github.com/WCD-DE/AE_Project_Student/tree/main/project_lambda_function)


