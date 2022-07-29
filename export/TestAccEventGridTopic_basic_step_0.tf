
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220729032718286846"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-220729032718286846"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
