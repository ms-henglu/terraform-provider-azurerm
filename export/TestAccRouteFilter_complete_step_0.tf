
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220408051646076198"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf220408051646076198"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

}
