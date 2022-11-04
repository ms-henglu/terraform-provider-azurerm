
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221104005727231875"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf221104005727231875"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
