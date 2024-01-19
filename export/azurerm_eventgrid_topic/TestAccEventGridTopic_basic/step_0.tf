
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025027137011"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-240119025027137011"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
