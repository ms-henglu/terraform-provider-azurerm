
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220818235323547770"
  location = "West Europe"
}



resource "azurerm_load_test" "test" {
  name                = "acctestALT-220818235323547770"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
