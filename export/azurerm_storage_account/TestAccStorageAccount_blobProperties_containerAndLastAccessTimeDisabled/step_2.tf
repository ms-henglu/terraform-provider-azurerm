
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestAzureRMSA-240311033238616428"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acct9rcfc"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    cors_rule {
      allowed_origins    = ["http://www.example.com"]
      exposed_headers    = ["x-tempo-*", "x-method-*"]
      allowed_headers    = ["*"]
      allowed_methods    = ["GET"]
      max_age_in_seconds = "2000000000"
    }

    cors_rule {
      allowed_origins    = ["http://www.test.com"]
      exposed_headers    = ["x-tempo-*"]
      allowed_headers    = ["*"]
      allowed_methods    = ["PUT"]
      max_age_in_seconds = "1000"
    }

    delete_retention_policy {
    }
  }
}
