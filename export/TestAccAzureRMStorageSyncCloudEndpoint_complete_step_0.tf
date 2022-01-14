

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-StorageSync-220114014844328616"
  location = "West Europe"
}

resource "azurerm_storage_sync" "test" {
  name                = "acctest-StorageSync-220114014844328616"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_storage_sync_group" "test" {
  name            = "acctest-StorageSyncGroup-220114014844328616"
  storage_sync_id = azurerm_storage_sync.test.id
}

resource "azurerm_storage_account" "test" {
  name                     = "accstr0cxfz"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "test" {
  name                 = "acctest-share-220114014844328616"
  storage_account_name = azurerm_storage_account.test.name

  acl {
    id = "GhostedRecall"
    access_policy {
      permissions = "r"
    }
  }
}


resource "azurerm_storage_sync_cloud_endpoint" "test" {
  name                      = "acctest-CEP-220114014844328616"
  storage_sync_group_id     = azurerm_storage_sync_group.test.id
  storage_account_id        = azurerm_storage_account.test.id
  storage_account_tenant_id = "ARM_TENANT_ID"
  file_share_name           = azurerm_storage_share.test.name
}
