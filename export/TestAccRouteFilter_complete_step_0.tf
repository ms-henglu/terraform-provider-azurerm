
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826003111900214"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf220826003111900214"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

}
