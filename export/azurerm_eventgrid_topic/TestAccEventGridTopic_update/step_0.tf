
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707010351277035"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-230707010351277035"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
