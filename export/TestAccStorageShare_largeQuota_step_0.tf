
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storageshare-220415031155641738"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsharem2syu"
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
  name                 = "testsharem2syu"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 6000
}
