
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726015121252509"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf220726015121252509"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
