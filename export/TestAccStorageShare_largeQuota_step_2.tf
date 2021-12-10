
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storageshare-211210025124950025"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsharedebx6"
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
  name                 = "testsharedebx6"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 10000
}
