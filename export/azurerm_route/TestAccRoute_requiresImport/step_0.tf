
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014003174204"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt221111014003174204"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_route" "test" {
  name                = "acctestroute221111014003174204"
  resource_group_name = azurerm_resource_group.test.name
  route_table_name    = azurerm_route_table.test.name

  address_prefix = "10.1.0.0/16"
  next_hop_type  = "VnetLocal"
}
