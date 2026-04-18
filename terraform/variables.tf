# passed in by env vars (TF_VAR)
variable "AIRBYTE_CLIENT_ID" {
  type      = string
  sensitive = true
}
variable "AIRBYTE_CLIENT_SECRET" {
  type      = string
  sensitive = true
}
variable "AIRBYTE_WORKSPACE_ID" {
  type      = string
  sensitive = true
}
variable "RDS_HOST" {
  type = string
  sensitive = true
}
variable "RDS_PORT" {
  type = number
  sensitive = true
}
variable "RDS_DATABASE" {
  type = string
  sensitive = true
}
variable "RDS_USERNAME" {
  type = string
  sensitive = true
}
variable "RDS_PASSWORD" {
  type = string
  sensitive = true
}
variable "RDS_SCHEMA" {
  type = string
  sensitive =  true
}
variable "SNOWFLAKE_ACCOUNT_ID_HOST" {
  type = string
  sensitive =  true
}
variable "SNOWFLAKE_ROLE" {
  type = string
  sensitive =  true
}
variable "SNOWFLAKE_USERNAME" {
  type = string
  sensitive =  true
}
variable "SNOWFLAKE_PASSWORD" {
  type = string
  sensitive =  true
}
variable "SNOWFLAKE_WAREHOUSE" {
  type = string
  sensitive =  true
}
variable "SNOWFLAKE_DATABASE" {
  type = string
  sensitive =  true
}
variable "SNOWFLAKE_SCHEMA" {
  type = string
  sensitive =  true
}
