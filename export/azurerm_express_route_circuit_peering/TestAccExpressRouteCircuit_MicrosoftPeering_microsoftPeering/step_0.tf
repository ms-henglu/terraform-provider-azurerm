
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023921291096"
  location = "West Europe"
}

resource "azurerm_express_route_circuit" "test" {
  name                  = "acctest-erc-230915023921291096"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  service_provider_name = "Equinix"
  peering_location      = "Silicon Valley"
  bandwidth_in_mbps     = 50

  sku {
    tier   = "Premium"
    family = "MeteredData"
  }

  tags = {
    Environment = "production"
    Purpose     = "AcceptanceTests"
  }
}

resource "azurerm_express_route_circuit_peering" "test" {
  peering_type                  = "MicrosoftPeering"
  express_route_circuit_name    = azurerm_express_route_circuit.test.name
  resource_group_name           = azurerm_resource_group.test.name
  peer_asn                      = 100
  primary_peer_address_prefix   = "192.168.1.0/30"
  secondary_peer_address_prefix = "192.168.2.0/30"
  vlan_id                       = 300

  microsoft_peering_config {
    advertised_public_prefixes = ["123.1.0.0/24"]
    advertised_communities     = ["regionalCommunity"]
  }
}
