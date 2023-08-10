
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-expressroute-230810143940955031"
  location = "West Europe"
}

resource "azurerm_express_route_circuit" "test" {
  name                  = "acctest-erc-230810143940955031"
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
    Env     = "Test"
    Purpose = "AcceptanceTests"
  }
}

resource "azurerm_express_route_circuit_peering" "test" {
  peering_type                  = "MicrosoftPeering"
  express_route_circuit_name    = azurerm_express_route_circuit.test.name
  resource_group_name           = azurerm_resource_group.test.name
  peer_asn                      = 100
  primary_peer_address_prefix   = "192.168.9.0/30"
  secondary_peer_address_prefix = "192.168.10.0/30"
  vlan_id                       = 300

  microsoft_peering_config {
    advertised_public_prefixes = ["123.5.0.0/24"]
  }
  ipv6 {
    primary_peer_address_prefix   = "2002:db05::/126"
    secondary_peer_address_prefix = "2003:db05::/126"

    microsoft_peering {
      advertised_public_prefixes = ["2002:db05::/126"]
      customer_asn               = 64511
      routing_registry_name      = "ARIN"
    }
  }
}
