
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527711937"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf240119025527711937"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
