

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527710616"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf240119025527710616"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_route_filter" "import" {
  name                = azurerm_route_filter.test.name
  location            = azurerm_route_filter.test.location
  resource_group_name = azurerm_route_filter.test.resource_group_name
}
