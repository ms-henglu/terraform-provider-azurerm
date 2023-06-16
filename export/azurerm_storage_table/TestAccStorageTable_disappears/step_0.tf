
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616075534202044"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccg3gh7"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst230616075534202044"
  storage_account_name = azurerm_storage_account.test.name
}
