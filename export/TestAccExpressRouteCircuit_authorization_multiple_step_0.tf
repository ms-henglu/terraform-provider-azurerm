
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014936425961"
  location = "West Europe"
}

resource "azurerm_express_route_circuit" "test" {
  name                  = "acctest-erc-211015014936425961"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  service_provider_name = "Equinix"
  peering_location      = "Silicon Valley"
  bandwidth_in_mbps     = 50

  sku {
    tier   = "Standard"
    family = "MeteredData"
  }

  allow_classic_operations = false

  tags = {
    Environment = "production"
    Purpose     = "AcceptanceTests"
  }
}

resource "azurerm_express_route_circuit_authorization" "test1" {
  name                       = "acctestauth1211015014936425961"
  express_route_circuit_name = azurerm_express_route_circuit.test.name
  resource_group_name        = azurerm_resource_group.test.name
}

resource "azurerm_express_route_circuit_authorization" "test2" {
  name                       = "acctestauth2211015014936425961"
  express_route_circuit_name = azurerm_express_route_circuit.test.name
  resource_group_name        = azurerm_resource_group.test.name
}
