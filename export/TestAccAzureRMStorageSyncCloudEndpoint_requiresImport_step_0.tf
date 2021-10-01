

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-StorageSync-211001054231766565"
  location = "West Europe"
}

resource "azurerm_storage_sync" "test" {
  name                = "acctest-StorageSync-211001054231766565"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_storage_sync_group" "test" {
  name            = "acctest-StorageSyncGroup-211001054231766565"
  storage_sync_id = azurerm_storage_sync.test.id
}

resource "azurerm_storage_account" "test" {
  name                     = "accstrgdypb"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "test" {
  name                 = "acctest-share-211001054231766565"
  storage_account_name = azurerm_storage_account.test.name

  acl {
    id = "GhostedRecall"
    access_policy {
      permissions = "r"
    }
  }
}


resource "azurerm_storage_sync_cloud_endpoint" "test" {
  name                  = "acctest-CEP-211001054231766565"
  storage_sync_group_id = azurerm_storage_sync_group.test.id
  storage_account_id    = azurerm_storage_account.test.id
  file_share_name       = azurerm_storage_share.test.name
}
