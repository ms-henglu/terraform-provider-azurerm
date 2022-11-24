
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124182052960188"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf221124182052960188"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
