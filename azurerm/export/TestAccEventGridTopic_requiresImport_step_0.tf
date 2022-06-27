
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627125845814172"
  location = "westus2"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-220627125845814172"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
