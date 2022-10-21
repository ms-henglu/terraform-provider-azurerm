
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storageshare-221021034640330328"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestshareopd0y"
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
  name                 = "testshareopd0y"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 10000
}
