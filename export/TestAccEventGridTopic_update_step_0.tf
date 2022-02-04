
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204060037471438"
  location = "westus2"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-220204060037471438"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
