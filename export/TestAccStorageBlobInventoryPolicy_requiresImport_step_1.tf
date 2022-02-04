


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-220204093639862362"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacclwhzh"
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
      blob_types = ["blockBlob"]
    }
  }
}


resource "azurerm_storage_blob_inventory_policy" "import" {
  storage_account_id     = azurerm_storage_blob_inventory_policy.test.storage_account_id
  storage_container_name = azurerm_storage_blob_inventory_policy.test.storage_container_name
  rules {
    name = tolist(azurerm_storage_blob_inventory_policy.test.rules).0.name
    filter {
      blob_types = tolist(azurerm_storage_blob_inventory_policy.test.rules).0.filter.0.blob_types

    }
  }
}
