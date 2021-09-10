
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210910021721131958"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf210910021721131958"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
