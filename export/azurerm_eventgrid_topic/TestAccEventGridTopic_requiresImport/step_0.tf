
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230113181110697611"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-230113181110697611"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
