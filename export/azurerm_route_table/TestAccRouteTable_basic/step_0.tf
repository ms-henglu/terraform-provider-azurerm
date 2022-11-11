
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111020925348148"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt221111020925348148"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
