

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105061256817269"
  location = "West Europe"
}

resource "azurerm_express_route_circuit" "test" {
  name                  = "acctest-erc-240105061256817269"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  service_provider_name = "Equinix"
  peering_location      = "Silicon Valley"
  bandwidth_in_mbps     = 50

  sku {
    tier   = "Standard"
    family = "MeteredData"
  }

  tags = {
    Environment = "production"
    Purpose     = "AcceptanceTests"
  }
}

resource "azurerm_express_route_circuit_peering" "test" {
  peering_type                  = "AzurePrivatePeering"
  express_route_circuit_name    = azurerm_express_route_circuit.test.name
  resource_group_name           = azurerm_resource_group.test.name
  shared_key                    = "SSSSsssssshhhhhItsASecret"
  peer_asn                      = 100
  primary_peer_address_prefix   = "192.168.1.0/30"
  secondary_peer_address_prefix = "192.168.2.0/30"
  vlan_id                       = 100
}


resource "azurerm_express_route_circuit_peering" "import" {
  peering_type                  = azurerm_express_route_circuit_peering.test.peering_type
  express_route_circuit_name    = azurerm_express_route_circuit_peering.test.express_route_circuit_name
  resource_group_name           = azurerm_express_route_circuit_peering.test.resource_group_name
  shared_key                    = azurerm_express_route_circuit_peering.test.shared_key
  peer_asn                      = azurerm_express_route_circuit_peering.test.peer_asn
  primary_peer_address_prefix   = azurerm_express_route_circuit_peering.test.primary_peer_address_prefix
  secondary_peer_address_prefix = azurerm_express_route_circuit_peering.test.secondary_peer_address_prefix
  vlan_id                       = azurerm_express_route_circuit_peering.test.vlan_id
}
