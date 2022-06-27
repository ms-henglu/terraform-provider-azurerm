
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627124517843080"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf220627124517843080"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
