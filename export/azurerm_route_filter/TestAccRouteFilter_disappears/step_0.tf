
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230316222026178178"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf230316222026178178"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
