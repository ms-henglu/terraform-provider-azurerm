
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-SS-220916012108825046"
  location = "West Europe"
}

resource "azurerm_storage_sync" "test" {
  name                = "acctest-StorageSync-220916012108825046"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_storage_sync_group" "test" {
  name            = "acctest-StorageSyncGroup-220916012108825046"
  storage_sync_id = azurerm_storage_sync.test.id
}
