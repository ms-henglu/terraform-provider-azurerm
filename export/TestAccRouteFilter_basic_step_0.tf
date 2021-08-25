
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825030045168973"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf210825030045168973"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
