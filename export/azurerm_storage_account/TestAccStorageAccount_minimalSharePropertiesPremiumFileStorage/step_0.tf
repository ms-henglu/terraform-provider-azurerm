
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-240119025908685317"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctuiigz"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "FileStorage"

  share_properties {
    retention_policy {
      days = 5
    }
  }

  lifecycle {
    ignore_changes = [share_properties.0.smb]
  }
}
