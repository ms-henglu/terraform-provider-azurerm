
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230313022003328458"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccup4bt"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst230313022003328458"
  storage_account_name = azurerm_storage_account.test.name
}
