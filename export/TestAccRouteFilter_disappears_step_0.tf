
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220128052857320794"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf220128052857320794"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
