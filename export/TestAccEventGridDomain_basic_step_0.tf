
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044411471287"
  location = "West Europe"
}

resource "azurerm_eventgrid_domain" "test" {
  name                = "acctesteg-211008044411471287"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
