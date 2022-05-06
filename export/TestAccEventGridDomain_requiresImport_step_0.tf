
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220506015913316627"
  location = "West Europe"
}

resource "azurerm_eventgrid_domain" "test" {
  name                = "acctesteg-220506015913316627"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
