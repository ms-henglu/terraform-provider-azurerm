
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-expressroutecircuit-240311032742145920"
  location = "West Europe"
}

resource "azurerm_express_route_port" "test" {
  name                = "acctest-ERP-240311032742145920"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  peering_location    = "Airtel-Chennai2-CLS"
  bandwidth_in_gbps   = 10
  encapsulation       = "Dot1Q"
}

resource "azurerm_express_route_circuit" "test" {
  name                  = "acctest-ExpressRouteCircuit-240311032742145920"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  express_route_port_id = azurerm_express_route_port.test.id
  bandwidth_in_gbps     = 5

  sku {
    tier   = "Standard"
    family = "MeteredData"
  }
}
