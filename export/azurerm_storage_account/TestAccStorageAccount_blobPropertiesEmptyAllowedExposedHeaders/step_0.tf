
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestAzureRMSA-221124182408374629"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2accto2qk6"
  resource_group_name = azurerm_resource_group.test.name

  location                        = azurerm_resource_group.test.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = true

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
