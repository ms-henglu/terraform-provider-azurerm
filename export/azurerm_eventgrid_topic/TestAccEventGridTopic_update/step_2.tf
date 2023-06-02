
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230602030516944387"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-230602030516944387"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  local_auth_enabled  = false
}
