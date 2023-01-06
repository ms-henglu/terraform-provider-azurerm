
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106031435792883"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-230106031435792883"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
