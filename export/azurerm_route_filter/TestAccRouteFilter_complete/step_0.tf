
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512011140768921"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf230512011140768921"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

}
