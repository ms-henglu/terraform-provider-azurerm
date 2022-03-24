
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220324163333261267"
  location = "West Europe"
}

resource "azurerm_eventgrid_domain" "test" {
  name                = "acctesteg-220324163333261267"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
