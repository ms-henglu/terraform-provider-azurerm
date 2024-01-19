
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119022552640853"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf240119022552640853"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

}
