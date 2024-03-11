
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311032056394841"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-240311032056394841"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
