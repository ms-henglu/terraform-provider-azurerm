
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021034418179646"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf221021034418179646"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
