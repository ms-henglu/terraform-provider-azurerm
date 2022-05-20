
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220520041012512032"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf220520041012512032"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
