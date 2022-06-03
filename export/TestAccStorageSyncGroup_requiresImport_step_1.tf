

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-SS-220603005355507519"
  location = "West Europe"
}

resource "azurerm_storage_sync" "test" {
  name                = "acctest-StorageSync-220603005355507519"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_storage_sync_group" "test" {
  name            = "acctest-StorageSyncGroup-220603005355507519"
  storage_sync_id = azurerm_storage_sync.test.id
}


resource "azurerm_storage_sync_group" "import" {
  name            = azurerm_storage_sync_group.test.name
  storage_sync_id = azurerm_storage_sync.test.id
}
