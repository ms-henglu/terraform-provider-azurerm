
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429065510675619"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-220429065510675619"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
