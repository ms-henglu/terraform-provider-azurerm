
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105064326639694"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf240105064326639694"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
