
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526085106709351"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-230526085106709351"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
