
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230609092113274822"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccld936"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

resource "azurerm_storage_share" "test" {
  name                 = "testshareld936"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 100
  enabled_protocol     = "SMB"
  access_tier          = "TransactionOptimized"
}
