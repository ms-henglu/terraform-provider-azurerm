
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221019060610893358"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-221019060610893358"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
