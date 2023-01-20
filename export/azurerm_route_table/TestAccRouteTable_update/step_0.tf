
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230120052449015780"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230120052449015780"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
