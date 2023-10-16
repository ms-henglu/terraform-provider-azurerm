


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-StorageSync-231016034824826422"
  location = "West Europe"
}

resource "azurerm_storage_sync" "test" {
  name                = "acctest-StorageSync-231016034824826422"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_storage_sync_group" "test" {
  name            = "acctest-StorageSyncGroup-231016034824826422"
  storage_sync_id = azurerm_storage_sync.test.id
}

resource "azurerm_storage_account" "test" {
  name                     = "accstrjam3b"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "test" {
  name                 = "acctest-share-231016034824826422"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 1

  acl {
    id = "GhostedRecall"
    access_policy {
      permissions = "r"
    }
  }
}


resource "azurerm_storage_sync_cloud_endpoint" "test" {
  name                  = "acctest-CEP-231016034824826422"
  storage_sync_group_id = azurerm_storage_sync_group.test.id
  storage_account_id    = azurerm_storage_account.test.id
  file_share_name       = azurerm_storage_share.test.name
}


resource "azurerm_storage_sync_cloud_endpoint" "import" {
  name                  = azurerm_storage_sync_cloud_endpoint.test.name
  storage_sync_group_id = azurerm_storage_sync_cloud_endpoint.test.storage_sync_group_id
  storage_account_id    = azurerm_storage_sync_cloud_endpoint.test.storage_account_id
  file_share_name       = azurerm_storage_sync_cloud_endpoint.test.file_share_name
}
