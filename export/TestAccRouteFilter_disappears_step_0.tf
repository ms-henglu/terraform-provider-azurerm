
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211203161718317212"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf211203161718317212"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
