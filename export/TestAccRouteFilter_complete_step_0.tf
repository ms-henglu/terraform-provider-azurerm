
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220415030905618696"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf220415030905618696"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

}
