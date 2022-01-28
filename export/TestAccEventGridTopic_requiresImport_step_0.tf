
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220128052520905417"
  location = "westus2"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-220128052520905417"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
