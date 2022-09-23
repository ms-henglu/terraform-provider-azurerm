
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-expressroutecircuit-220923012150619348"
  location = "West Europe"
}

resource "azurerm_express_route_port" "test" {
  name                = "acctest-ERP-220923012150619348"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  peering_location    = "Airtel-Chennai2-CLS"
  bandwidth_in_gbps   = 10
  encapsulation       = "Dot1Q"
}

resource "azurerm_express_route_circuit" "test" {
  name                  = "acctest-ExpressRouteCircuit-220923012150619348"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  express_route_port_id = azurerm_express_route_port.test.id
  bandwidth_in_gbps     = 10

  sku {
    tier   = "Standard"
    family = "MeteredData"
  }
}
