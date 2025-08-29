# Project Creation Steps
Notes are from Week 4 Lecture 2 - Airbyte, Lambda & Project Data Ingestion

## Part 0 : Create Environments
```bash
touch .gitignore

```
## Part 1: Snowflake 
* Instructions in `Week 4 - Exercise 1-Snowflake` & `Week 4 - Lecture 2 - Airbyte, Lambda & Project Data Ingestion` Notes
* Use the warehouse - `compute_wh`
* In the snowflake console create the following:
    * Code can be here : [Wk4_Lec2_Retail_Project worksheet]()
    * Database - `tpcds`
    * schema - `raw`
    * new user - `wcd_midterm_load_user` (give password too)
    * grant role- `accountadmin`
    * table - `inventory`

## Part 2: Lambda Function Creation
* Goto AWS console
* Create the lambda function
* Give the lambda function an IAM role access to the bucket with the data (we are not able to use the requests to get the file directly from the url)
    * IAM -> Policy -> Create Policy -> JSON
    * Attach a policy like name `S3GetTpcds`
    ```json
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Action": ["s3:GetObject"],
        "Resource": "arn:aws:s3:::de-materials-tpcds/*"
        }
    ]
    }
    ```
    * IAM -> Role -> Create Role `access_tpcds_bucket`-> AWS Service -> Lambda -> Attach Policy -> Attach the Custom Policy `S3GetTpcds`

    * 
* Write the code to do the following
    * pull data file from url using requests
    * write the file locally to `/tmp` folder on lambda
    * create file format on snowflake
    * create stage on snowflake
    * put file from `/tmp` to snowflake stage
    * list stage
    * copy data from stage to table
* Deploy and test the lambda functions to know which packages are missing in lambda that you need to add to the layer
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

* Increase the processing capacity of the lambda funciton

## Improvements
* Create lambda function via AWS CLI rather than the AWS Console


## Resources:
* Course Github for project [here](https://github.com/WCD-DE/AE_Project_Student/tree/main/project_lambda_function)


