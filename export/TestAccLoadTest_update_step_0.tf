
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220513180439706912"
  location = "West Europe"
}



resource "azurerm_load_test" "test" {
  name                = "acctestALT-220513180439706912"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
