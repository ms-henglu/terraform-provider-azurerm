
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storageshare-220722040049211457"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestshare4p1t6"
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
  name                 = "testshare4p1t6"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 10000
}
