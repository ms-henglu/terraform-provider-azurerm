
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-expressroute-240112034901509517"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf240112034901509517"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  rule {
    name        = "acctestrule240112034901509517"
    access      = "Allow"
    rule_type   = "Community"
    communities = ["12076:52005", "12076:52006"]
  }
}

resource "azurerm_express_route_circuit" "test" {
  name                  = "acctest-erc-240112034901509517"
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
  primary_peer_address_prefix   = "192.168.11.0/30"
  secondary_peer_address_prefix = "192.168.12.0/30"
  vlan_id                       = 300
  route_filter_id               = azurerm_route_filter.test.id

  microsoft_peering_config {
    advertised_public_prefixes = ["123.3.0.0/24"]
  }

  ipv6 {
    primary_peer_address_prefix   = "2002:db02::/126"
    secondary_peer_address_prefix = "2003:db02::/126"
    route_filter_id               = azurerm_route_filter.test.id

    microsoft_peering {
      advertised_public_prefixes = ["2002:db01::/126"]
      customer_asn               = 64511
      routing_registry_name      = "ARIN"
    }
  }
}
