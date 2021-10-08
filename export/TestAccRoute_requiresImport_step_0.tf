
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044745630870"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt211008044745630870"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_route" "test" {
  name                = "acctestroute211008044745630870"
  resource_group_name = azurerm_resource_group.test.name
  route_table_name    = azurerm_route_table.test.name

  address_prefix = "10.1.0.0/16"
  next_hop_type  = "vnetlocal"
}
