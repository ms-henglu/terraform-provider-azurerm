
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211112021327248617"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccvg4x1"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "FileStorage"
  account_tier             = "Premium"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "test" {
  name                 = "testsharevg4x1"
  storage_account_name = azurerm_storage_account.test.name
  enabled_protocol     = "NFS"
}
