
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627124156113797"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-220627124156113797"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
