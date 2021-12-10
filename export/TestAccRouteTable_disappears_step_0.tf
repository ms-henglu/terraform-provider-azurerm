
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210024904052446"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt211210024904052446"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
