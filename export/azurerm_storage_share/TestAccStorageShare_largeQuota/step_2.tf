
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storageshare-231016034824828533"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestshare8jcz9"
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
  name                 = "testshare8jcz9"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 10000
}
