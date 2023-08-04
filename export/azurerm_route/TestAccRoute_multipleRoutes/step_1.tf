
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804030421794733"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230804030421794733"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_route" "test" {
  name                = "acctestroute230804030421794733"
  resource_group_name = azurerm_resource_group.test.name
  route_table_name    = azurerm_route_table.test.name

  address_prefix = "10.1.0.0/16"
  next_hop_type  = "VnetLocal"
}

resource "azurerm_route" "test1" {
  name                = "acctestroute2308040304217947331"
  resource_group_name = azurerm_resource_group.test.name
  route_table_name    = azurerm_route_table.test.name

  address_prefix = "10.2.0.0/16"
  next_hop_type  = "None"
}
