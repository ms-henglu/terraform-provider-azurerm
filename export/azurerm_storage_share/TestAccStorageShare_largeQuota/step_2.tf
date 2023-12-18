
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storageshare-231218072636513111"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestshareej7i2"
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
  name                 = "testshareej7i2"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 10000
}
