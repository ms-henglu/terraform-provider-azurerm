

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-SS-220826003348658520"
  location = "West Europe"
}

resource "azurerm_storage_sync" "test" {
  name                = "acctest-StorageSync-220826003348658520"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_storage_sync_group" "test" {
  name            = "acctest-StorageSyncGroup-220826003348658520"
  storage_sync_id = azurerm_storage_sync.test.id
}


resource "azurerm_storage_sync_group" "import" {
  name            = azurerm_storage_sync_group.test.name
  storage_sync_id = azurerm_storage_sync.test.id
}
