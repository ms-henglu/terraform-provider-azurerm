
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230602030516943576"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-230602030516943576"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
