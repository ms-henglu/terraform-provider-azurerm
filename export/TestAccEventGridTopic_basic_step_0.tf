
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014231550177"
  location = "westus2"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-211015014231550177"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
