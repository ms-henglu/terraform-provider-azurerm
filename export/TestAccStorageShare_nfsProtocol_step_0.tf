
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220128083028477591"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccxe6h3"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "FileStorage"
  account_tier             = "Premium"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "test" {
  name                 = "testsharexe6h3"
  storage_account_name = azurerm_storage_account.test.name
  enabled_protocol     = "NFS"
}
