
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220722035741117408"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf220722035741117408"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
