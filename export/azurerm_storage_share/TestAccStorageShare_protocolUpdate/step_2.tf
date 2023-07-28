
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728033146230285"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc3uns6"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "FileStorage"
  account_tier             = "Premium"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "test" {
  name                 = "testshare3uns6"
  storage_account_name = azurerm_storage_account.test.name
  enabled_protocol     = "SMB"
  quota                = 100
}
