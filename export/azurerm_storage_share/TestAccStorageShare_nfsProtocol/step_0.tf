
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034824821825"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccsu084"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "FileStorage"
  account_tier             = "Premium"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "test" {
  name                 = "testsharesu084"
  storage_account_name = azurerm_storage_account.test.name
  enabled_protocol     = "NFS"
  quota                = 100
}
