

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106031750851240"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf230106031750851240"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_route_filter" "import" {
  name                = azurerm_route_filter.test.name
  location            = azurerm_route_filter.test.location
  resource_group_name = azurerm_route_filter.test.resource_group_name
}
