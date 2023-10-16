
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034431020739"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf231016034431020739"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
