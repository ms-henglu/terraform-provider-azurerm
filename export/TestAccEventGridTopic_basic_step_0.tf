
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211021235007388677"
  location = "westus2"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-211021235007388677"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
