
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-expressroutecircuit-210928075747609849"
  location = "West Europe"
}

resource "azurerm_express_route_port" "test" {
  name                = "acctest-ERP-210928075747609849"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  peering_location    = "Airtel-Chennai2-CLS"
  bandwidth_in_gbps   = 10
  encapsulation       = "Dot1Q"
}

resource "azurerm_express_route_circuit" "test" {
  name                  = "acctest-ExpressRouteCircuit-210928075747609849"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  express_route_port_id = azurerm_express_route_port.test.id
  bandwidth_in_gbps     = 10

  sku {
    tier   = "Standard"
    family = "MeteredData"
  }
}
