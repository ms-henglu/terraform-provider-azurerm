
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220324163741699838"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf220324163741699838"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
