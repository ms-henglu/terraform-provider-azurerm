

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-erconnection-231013043954285180"
  location = "West Europe"
}

resource "azurerm_express_route_port" "test" {
  name                = "acctest-erp-231013043954285180"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  peering_location    = "CDC-Canberra"
  bandwidth_in_gbps   = 10
  encapsulation       = "Dot1Q"
}

resource "azurerm_express_route_circuit" "test" {
  name                  = "acctest-erc-231013043954285180"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  express_route_port_id = azurerm_express_route_port.test.id
  bandwidth_in_gbps     = 5

  sku {
    tier   = "Premium"
    family = "MeteredData"
  }
}

resource "azurerm_express_route_circuit_peering" "test" {
  peering_type                  = "AzurePrivatePeering"
  express_route_circuit_name    = azurerm_express_route_circuit.test.name
  resource_group_name           = azurerm_resource_group.test.name
  shared_key                    = "ItsASecret"
  peer_asn                      = 100
  primary_peer_address_prefix   = "192.168.1.0/30"
  secondary_peer_address_prefix = "192.168.2.0/30"
  vlan_id                       = 100
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctest-vwan-231013043954285180"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctest-vhub-231013043954285180"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_prefix      = "10.0.1.0/24"
}

resource "azurerm_express_route_gateway" "test" {
  name                = "acctest-ergw-231013043954285180"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_hub_id      = azurerm_virtual_hub.test.id
  scale_units         = 1
}


resource "azurerm_route_map" "routemap1" {
  name           = "routemapfirst"
  virtual_hub_id = azurerm_virtual_hub.test.id

  rule {
    name                 = "rule1"
    next_step_if_matched = "Continue"

    action {
      type = "Add"

      parameter {
        as_path = ["22334"]
      }
    }

    match_criterion {
      match_condition = "Contains"
      route_prefix    = ["10.0.0.0/8"]
    }
  }
}

resource "azurerm_route_map" "routemap2" {
  name           = "routemapsecond"
  virtual_hub_id = azurerm_virtual_hub.test.id

  rule {
    name                 = "rule1"
    next_step_if_matched = "Continue"

    action {
      type = "Add"

      parameter {
        as_path = ["22334"]
      }
    }

    match_criterion {
      match_condition = "Contains"
      route_prefix    = ["10.0.0.0/8"]
    }
  }
}

resource "azurerm_express_route_connection" "test" {
  name                                 = "acctest-ExpressRouteConnection-231013043954285180"
  express_route_gateway_id             = azurerm_express_route_gateway.test.id
  express_route_circuit_peering_id     = azurerm_express_route_circuit_peering.test.id
  routing_weight                       = 2
  authorization_key                    = "90f8db47-e25b-4b65-a68b-7743ced2a16b"
  enable_internet_security             = true
  express_route_gateway_bypass_enabled = true

  routing {
    associated_route_table_id = azurerm_virtual_hub.test.default_route_table_id

    propagated_route_table {
      labels          = ["label1"]
      route_table_ids = [azurerm_virtual_hub.test.default_route_table_id]
    }

    inbound_route_map_id  = azurerm_route_map.routemap1.id
    outbound_route_map_id = azurerm_route_map.routemap2.id
  }
  depends_on = [azurerm_route_map.routemap1, azurerm_route_map.routemap2]
}
