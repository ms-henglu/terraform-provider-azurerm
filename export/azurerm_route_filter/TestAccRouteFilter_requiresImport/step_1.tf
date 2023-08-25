

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825025022024588"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf230825025022024588"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_route_filter" "import" {
  name                = azurerm_route_filter.test.name
  location            = azurerm_route_filter.test.location
  resource_group_name = azurerm_route_filter.test.resource_group_name
}
