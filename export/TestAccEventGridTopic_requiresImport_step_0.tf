
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825031654053418"
  location = "westus2"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-210825031654053418"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
