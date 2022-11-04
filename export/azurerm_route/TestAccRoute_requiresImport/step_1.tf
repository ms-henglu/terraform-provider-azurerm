

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221104005727233905"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt221104005727233905"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_route" "test" {
  name                = "acctestroute221104005727233905"
  resource_group_name = azurerm_resource_group.test.name
  route_table_name    = azurerm_route_table.test.name

  address_prefix = "10.1.0.0/16"
  next_hop_type  = "VnetLocal"
}

resource "azurerm_route" "import" {
  name                = azurerm_route.test.name
  resource_group_name = azurerm_route.test.resource_group_name
  route_table_name    = azurerm_route.test.route_table_name

  address_prefix = azurerm_route.test.address_prefix
  next_hop_type  = azurerm_route.test.next_hop_type
}
