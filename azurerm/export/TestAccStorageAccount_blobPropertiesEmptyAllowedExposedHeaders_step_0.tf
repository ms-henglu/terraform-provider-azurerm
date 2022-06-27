
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestAzureRMSA-220627132416485800"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctqz1l8"
  resource_group_name = azurerm_resource_group.test.name

  location                  = azurerm_resource_group.test.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  allow_blob_public_access  = true

  blob_properties {
    cors_rule {
      allowed_headers    = [""]
      exposed_headers    = [""]
      allowed_origins    = ["*"]
      allowed_methods    = ["GET"]
      max_age_in_seconds = 3600
    }
  }
}
