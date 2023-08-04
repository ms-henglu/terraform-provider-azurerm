
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storageshare-230804030801350540"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsharezo9jz"
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
  name                 = "testsharezo9jz"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 10000
}
