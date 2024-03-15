
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315123704094357"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf240315123704094357"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
