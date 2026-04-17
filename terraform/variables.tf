# passed in by env vars (TF_VAR)
variable "CLIENT_ID" 
{
  type      = string
  sensitive = true
}
variable "CLIENT_SECRET" 
{
  type      = string
  sensitive = true
}

