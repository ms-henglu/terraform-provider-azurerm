
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210826023659328222"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf210826023659328222"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
