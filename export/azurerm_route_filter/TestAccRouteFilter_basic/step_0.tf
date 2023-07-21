
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721015711366442"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf230721015711366442"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
