
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014003170257"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt221111014003170257"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_route" "test" {
  name                = "acctestroute221111014003170257"
  resource_group_name = azurerm_resource_group.test.name
  route_table_name    = azurerm_route_table.test.name

  address_prefix = "10.1.0.0/16"
  next_hop_type  = "VnetLocal"
}

resource "azurerm_route" "test1" {
  name                = "acctestroute2211110140031702571"
  resource_group_name = azurerm_resource_group.test.name
  route_table_name    = azurerm_route_table.test.name

  address_prefix = "10.2.0.0/16"
  next_hop_type  = "None"
}
