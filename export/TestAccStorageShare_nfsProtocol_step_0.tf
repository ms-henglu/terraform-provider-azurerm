
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211126031741004492"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccdryoh"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "FileStorage"
  account_tier             = "Premium"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "test" {
  name                 = "testsharedryoh"
  storage_account_name = azurerm_storage_account.test.name
  enabled_protocol     = "NFS"
}
