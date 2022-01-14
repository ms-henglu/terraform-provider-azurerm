
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220114064721628193"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccd7bgy"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "FileStorage"
  account_tier             = "Premium"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "test" {
  name                 = "testshared7bgy"
  storage_account_name = azurerm_storage_account.test.name
  enabled_protocol     = "NFS"
}
