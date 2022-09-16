
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011826820125"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf220916011826820125"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
