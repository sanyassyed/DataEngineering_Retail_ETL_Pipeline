terraform {
  required_providers {
    airbyte = {
      source  = "airbytehq/airbyte"
      version = "~> 1.0"
    }
  }
}

provider "airbyte" {
  client_id     = var.CLIENT_ID
  client_secret = var.CLIENT_SECRET

  # Omit server_url for Airbyte Cloud (defaults to https://api.airbyte.com/v1)
  # server_url = "http://localhost:8000/api/public/v1/"
}