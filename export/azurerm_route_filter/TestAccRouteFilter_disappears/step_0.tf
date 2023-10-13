
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013043954330459"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf231013043954330459"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
