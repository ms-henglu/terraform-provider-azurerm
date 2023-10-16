
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestAzureRMSA-231016034824255312"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2accty11ce"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_kind             = "Storage"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    cors_rule {
      allowed_origins    = ["http://www.example.com"]
      exposed_headers    = ["x-tempo-*"]
      allowed_headers    = ["x-tempo-*"]
      allowed_methods    = ["GET", "PUT", "PATCH"]
      max_age_in_seconds = "500"
    }

    delete_retention_policy {
      days = 300
    }

    default_service_version = "2019-07-07"
    container_delete_retention_policy {
      days = 7
    }

    # Following properties are not supported for "Storage" (v1) kind
    last_access_time_enabled = false
    change_feed_enabled      = false
    versioning_enabled       = false
    # change_feed_retention_in_days
    # restore_policy
  }
}
