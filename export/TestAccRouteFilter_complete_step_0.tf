
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623234115656189"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf220623234115656189"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

}
