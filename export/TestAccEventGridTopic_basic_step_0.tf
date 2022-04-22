
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220422011850434645"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-220422011850434645"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
