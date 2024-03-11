
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-240311033238620681"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctj1jqv"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  share_properties {
    cors_rule {
      allowed_origins    = ["http://www.example.com"]
      exposed_headers    = ["x-tempo-*"]
      allowed_headers    = ["x-tempo-*"]
      allowed_methods    = ["GET", "PUT", "PATCH"]
      max_age_in_seconds = "500"
    }

    retention_policy {
      days = 300
    }

    smb {
      versions                        = ["SMB3.0"]
      authentication_types            = ["NTLMv2"]
      kerberos_ticket_encryption_type = ["AES-256"]
    }
  }
}
