
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221202040145002178"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt221202040145002178"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
