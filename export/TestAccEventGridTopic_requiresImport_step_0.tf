
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928055436502409"
  location = "westus2"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-210928055436502409"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
