
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220923012150647108"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf220923012150647108"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

}
