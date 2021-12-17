
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storageshare-211217035952790757"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestshare90z3u"
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
  name                 = "testshare90z3u"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 10000
}
