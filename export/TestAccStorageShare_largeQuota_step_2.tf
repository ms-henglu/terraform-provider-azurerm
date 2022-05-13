
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storageshare-220513023855456607"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestshare97lv8"
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
  name                 = "testshare97lv8"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 10000
}
