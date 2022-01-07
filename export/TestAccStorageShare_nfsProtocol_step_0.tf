
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220107034550847096"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccn9wws"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "FileStorage"
  account_tier             = "Premium"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "test" {
  name                 = "testsharen9wws"
  storage_account_name = azurerm_storage_account.test.name
  enabled_protocol     = "NFS"
}
