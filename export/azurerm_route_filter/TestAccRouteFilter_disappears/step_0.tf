
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230120052449007747"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf230120052449007747"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
