
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512011501855544"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccpqv6i"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "FileStorage"
}

resource "azurerm_storage_share" "test" {
  name                 = "testsharepqv6i"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 100
  enabled_protocol     = "SMB"
  access_tier          = "Premium"
}
