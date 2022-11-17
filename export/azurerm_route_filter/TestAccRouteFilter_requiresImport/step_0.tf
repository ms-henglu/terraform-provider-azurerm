
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221117231247906138"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf221117231247906138"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
