
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217075627677679"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf211217075627677679"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
