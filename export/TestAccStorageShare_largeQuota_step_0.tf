
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storageshare-211105040547642502"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestshare3wjz0"
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
  name                 = "testshare3wjz0"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 6000
}
