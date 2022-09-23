
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storageshare-220923012408557129"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsharetx2xg"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "FileStorage"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_share" "test" {
  name                 = "testsharetx2xg"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 10000
}
