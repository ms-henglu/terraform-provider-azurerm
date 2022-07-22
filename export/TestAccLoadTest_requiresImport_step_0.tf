
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220722035525633049"
  location = "West Europe"
}



resource "azurerm_load_test" "test" {
  name                = "acctestALT-220722035525633049"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
