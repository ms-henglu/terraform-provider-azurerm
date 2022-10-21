
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021034111594610"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-221021034111594610"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
