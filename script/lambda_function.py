import os
import toml
import boto3
import snowflake.connector as sf


def lambda_handler(event, context):
    
    # parameters
    destination_folder = "/tmp"
    file_name = "inventory.csv"
    file_path = os.path.join(destination_folder,file_name)

    # snowflake parameters
    app_config = toml.load('config.toml')
    user = app_config['snowflake']['user']
    password = app_config['snowflake']['password']
    account = app_config['snowflake']['account']
    warehouse = app_config['snowflake']['warehouse']
    database = app_config['snowflake']['database']
    schema = app_config['snowflake']['schema']
    table = app_config['snowflake']['table']
    role = app_config['snowflake']['role']
    stage_name = app_config['snowflake']['stage']
    
    # Your AWS Access Key and Secret
    aws_access_key_id = app_config['aws']['aws_access_key_id']
    aws_secret_access_key = app_config['aws']['aws_secret_access_key']
    
    # grab inventory file from s3 bucket
    client = boto3.client('s3', 
                          aws_access_key_id=aws_access_key_id,
                          aws_secret_access_key=aws_secret_access_key
                         )
    bucket = app_config['s3']['bucket']
    key = app_config['s3']['key']

    #client.head_object(Bucket=bucket, Key=key, RequestPayer='requester')
    client.download_file(Bucket=bucket, Key=key, Filename=file_path, ExtraArgs={'RequestPayer': 'requester'})
    

    # save file in /tmp/ folder
    with open(file_path, 'r') as f:
        file_content = f.read()
    print("File Content:")
    print(file_content)
    
    # connect to snowflake
    conn = sf.connect(user=user, password=password, account=account, warehouse=warehouse, database=database, schema=schema, role=role)

    cursor = conn.cursor()
    
    # create fileformat, stage, upload the file
    # set schema to use
    use_warehouse = f'use warehouse {warehouse}'
    cursor.execute(use_warehouse)

    # set schema to use
    use_schema = f'use schema {schema}'
    cursor.execute(use_schema)

    # create FILE FORMAT
    create_csv_format = f"CREATE OR REPLACE FILE FORMAT comma_csv TYPE = 'CSV' FIELD_DELIMITER = ',' NULL_IF = ('');"
    cursor.execute(create_csv_format)

    # create NAMED STAGE
    create_stage_query = f"CREATE OR REPLACE STAGE {stage_name} FILE_FORMAT = comma_csv;"
    cursor.execute(create_stage_query)

    # copy file from local to stage
    copy_into_stage_query = f"PUT 'file://{file_path}' @{stage_name};"
    cursor.execute(copy_into_stage_query)

    # list stage to see contents of that stage
    list_stage_query = f"LIST @{stage_name};"
    cursor.execute(list_stage_query)

    # trucate table
    truncate_table_query = f"TRUNCATE TABLE {schema}.{table};"
    cursor.execute(truncate_table_query)

    # copy into table
    copy_into_query = f"COPY INTO {schema}.{table} FROM @{stage_name} FILE_FORMAT = comma_csv;"
    cursor.execute(copy_into_query)

    print("File uploaded to Snowflake successfully")

    return {
        'statusCode': 200,
         'body': 'File downloaded and uploaded to Snowflake successfully.'
    }