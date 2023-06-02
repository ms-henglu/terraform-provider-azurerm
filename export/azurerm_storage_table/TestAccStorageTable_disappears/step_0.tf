
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230602031145277970"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacchivx4"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst230602031145277970"
  storage_account_name = azurerm_storage_account.test.name
}
