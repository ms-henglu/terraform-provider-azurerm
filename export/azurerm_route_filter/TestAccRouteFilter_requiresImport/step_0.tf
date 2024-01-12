
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112224958250683"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf240112224958250683"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
