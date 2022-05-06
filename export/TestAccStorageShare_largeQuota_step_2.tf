
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storageshare-220506010320428108"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsharen1zt7"
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
  name                 = "testsharen1zt7"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 10000
}
