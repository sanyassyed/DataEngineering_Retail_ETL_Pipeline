# Project Creation Steps
Notes are from Week 4 Lecture 2 - Airbyte, Lambda & Project Data Ingestion

## Part 1 : Pre-requisite
* **Host Machine**: environment to build the lambda layer
    * conda
    * aws cli
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
## Part 2: Snowflake 
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

## Part 3: Lambda Function Creation
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

## Codes:
* Lambda Function [lambda_funtion](../script/lambda_function.py)
* Config file [config.toml](../script/config.toml)
* Requirements File [requirements.txt](../script/requirements.txt)
* Snowflake Worksheet [Wk4_Lec2_Retail_Project worksheet]()

## Improvements
* Create lambda function via AWS CLI rather than the AWS Console


## Resources:
* Course Github for project [here](https://github.com/WCD-DE/AE_Project_Student/tree/main/project_lambda_function)


