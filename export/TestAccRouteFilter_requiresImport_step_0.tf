
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220124122446540752"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf220124122446540752"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
