
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001021055718661"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf211001021055718661"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
