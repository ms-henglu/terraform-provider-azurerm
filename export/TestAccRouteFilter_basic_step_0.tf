
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429065844299362"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf220429065844299362"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
