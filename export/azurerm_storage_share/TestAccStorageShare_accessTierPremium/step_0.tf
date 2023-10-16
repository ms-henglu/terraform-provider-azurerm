
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034824824052"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccb22ha"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "FileStorage"
}

resource "azurerm_storage_share" "test" {
  name                 = "testshareb22ha"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 100
  enabled_protocol     = "SMB"
  access_tier          = "Premium"
}
