


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-240112035239613442"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacczi6ud"
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
  storage_account_id = azurerm_storage_account.test.id
  rules {
    name                   = "rule1"
    storage_container_name = azurerm_storage_container.test.name
    format                 = "Csv"
    schedule               = "Daily"
    scope                  = "Container"
    schema_fields = [
      "Name",
      "Last-Modified",
    ]
  }
}


resource "azurerm_storage_blob_inventory_policy" "import" {
  storage_account_id = azurerm_storage_blob_inventory_policy.test.storage_account_id
  rules {
    name                   = tolist(azurerm_storage_blob_inventory_policy.test.rules).0.name
    storage_container_name = tolist(azurerm_storage_blob_inventory_policy.test.rules).0.storage_container_name
    format                 = tolist(azurerm_storage_blob_inventory_policy.test.rules).0.format
    schedule               = tolist(azurerm_storage_blob_inventory_policy.test.rules).0.schedule
    scope                  = tolist(azurerm_storage_blob_inventory_policy.test.rules).0.scope
    schema_fields          = tolist(azurerm_storage_blob_inventory_policy.test.rules).0.schema_fields
  }
}
