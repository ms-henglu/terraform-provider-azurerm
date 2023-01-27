
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230127045836056497"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf230127045836056497"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

}
