
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623234426962517"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccj6pfe"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst220623234426962517"
  storage_account_name = azurerm_storage_account.test.name
}
