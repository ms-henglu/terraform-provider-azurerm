
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230407023833886730"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf230407023833886730"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
