
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230313022003314328"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc3i8uz"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

resource "azurerm_storage_share" "test" {
  name                 = "testshare3i8uz"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 100
  enabled_protocol     = "SMB"
  access_tier          = "TransactionOptimized"
}
