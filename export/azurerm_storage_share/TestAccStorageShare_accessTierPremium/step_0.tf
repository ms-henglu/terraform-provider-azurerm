
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014332757119"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc4ypne"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "FileStorage"
}

resource "azurerm_storage_share" "test" {
  name                 = "testshare4ypne"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 100
  enabled_protocol     = "SMB"
  access_tier          = "Premium"
}
