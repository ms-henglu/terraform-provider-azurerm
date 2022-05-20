
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220520040657304362"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-220520040657304362"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
