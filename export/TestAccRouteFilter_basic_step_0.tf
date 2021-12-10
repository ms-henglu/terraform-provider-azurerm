
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210024904054361"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf211210024904054361"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
