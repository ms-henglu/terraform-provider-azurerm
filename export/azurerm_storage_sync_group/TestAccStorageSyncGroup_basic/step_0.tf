
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-SS-230804030801351640"
  location = "West Europe"
}

resource "azurerm_storage_sync" "test" {
  name                = "acctest-StorageSync-230804030801351640"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_storage_sync_group" "test" {
  name            = "acctest-StorageSyncGroup-230804030801351640"
  storage_sync_id = azurerm_storage_sync.test.id
}
