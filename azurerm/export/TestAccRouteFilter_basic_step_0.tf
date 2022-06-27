
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627130109777406"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf220627130109777406"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
