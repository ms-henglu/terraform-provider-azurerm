
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-SS-240119025909559184"
  location = "West Europe"
}

resource "azurerm_storage_sync" "test" {
  name                = "acctest-StorageSync-240119025909559184"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_storage_sync_group" "test" {
  name            = "acctest-StorageSyncGroup-240119025909559184"
  storage_sync_id = azurerm_storage_sync.test.id
}
