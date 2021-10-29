

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-211029020255465554"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc07h2c"
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
