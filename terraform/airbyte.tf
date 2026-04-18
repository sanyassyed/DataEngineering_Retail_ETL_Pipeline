# airbyte source 
data "airbyte_connector_configuration" "postgres_config" {
  connector_name = "source-postgres"

  configuration = {
    host     = var.RDS_HOST
    port     = var.RDS_PORT
    database = var.RDS_DATABASE
    username = var.RDS_USERNAME
    schemas  = [var.RDS_SCHEMA]
    ssl_mode = {mode = "require" }
    tunnel_method = { "tunnel_method": "NO_TUNNEL" }
    replication_method = { "method": "Xmin" }
    entra_service_principal_auth = false
  }

  configuration_secrets = {
    password = var.RDS_PASSWORD
  }
}

resource "airbyte_source" "postgres" {
  name          = " RdsPostgres"
  workspace_id  = var.AIRBYTE_WORKSPACE_ID
  definition_id = data.airbyte_connector_configuration.postgres_config.definition_id
  configuration = data.airbyte_connector_configuration.postgres_config.configuration_json
}

# todo: finish this
# airbyte destination



{
  "name": "Snowflake",
  "workspaceId": "2bc24ff6-db23-471f-b447-9bcffa88f5bb",
  "definitionId": "424892c4-daac-4491-b35d-c6688ba547ba",
  "configuration": {
    "host": "OQGWDZR-QU78153.snowflakecomputing.com",
    "role": "ACCOUNTADMIN",
    "schema": "RAW",
    "database": "TPCDS",
    "username": "sanyassyed1",
    "warehouse": "COMPUTE_WH",
    "credentials": {
      "password": "******",
      "auth_type": "Username and Password"
    },
    "disable_type_dedupe": false,
    "use_merge_for_upsert": false,
    "retention_period_days": 1
  }
}