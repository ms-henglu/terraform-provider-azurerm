
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storageshare-221111014332750243"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestshareuvutz"
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
  name                 = "testshareuvutz"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 6000
}
