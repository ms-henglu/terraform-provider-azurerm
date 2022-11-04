
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221104005727233408"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt221104005727233408"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
