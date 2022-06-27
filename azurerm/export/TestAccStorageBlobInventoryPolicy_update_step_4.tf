

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-220627123112150661"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacczqn7h"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "test" {
  name                  = "vhds"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}


resource "azurerm_storage_blob_inventory_policy" "test" {
  storage_account_id     = azurerm_storage_account.test.id
  storage_container_name = azurerm_storage_container.test.name
  rules {
    name = "rule1"
    filter {
      blob_types            = ["blockBlob", "pageBlob"]
      include_blob_versions = true
      include_snapshots     = true
      prefix_match          = ["*/test"]
    }
  }

  rules {
    name = "rule2"
    filter {
      blob_types            = ["appendBlob"]
      include_blob_versions = false
      include_snapshots     = true
      prefix_match          = ["prefix"]
    }
  }
}
