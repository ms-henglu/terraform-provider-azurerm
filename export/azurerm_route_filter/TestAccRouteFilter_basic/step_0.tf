
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221216013939233079"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf221216013939233079"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
