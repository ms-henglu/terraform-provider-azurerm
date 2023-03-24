
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230324052517251202"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf230324052517251202"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
