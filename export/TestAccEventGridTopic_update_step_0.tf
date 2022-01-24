
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220124125059590722"
  location = "westus2"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-220124125059590722"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
