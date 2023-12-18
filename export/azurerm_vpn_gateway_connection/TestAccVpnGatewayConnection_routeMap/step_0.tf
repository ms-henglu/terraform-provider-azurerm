

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vpn-231218072256498495"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctest-vwan-231218072256498495"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctest-vhub-231218072256498495"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_prefix      = "10.0.0.0/24"
}

resource "azurerm_vpn_gateway" "test" {
  name                = "acctest-vpngw-231218072256498495"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  virtual_hub_id      = azurerm_virtual_hub.test.id
}

resource "azurerm_vpn_site" "test" {
  name                = "acctest-vpnsite-231218072256498495"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_cidrs       = ["10.0.1.0/24"]

  link {
    name       = "link1"
    ip_address = "10.0.1.1"
  }

  link {
    name       = "link2"
    ip_address = "10.0.1.2"
  }
}


resource "azurerm_route_map" "test" {
  name           = "acctestrm-dwcnt"
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

resource "azurerm_route_map" "test2" {
  name           = "acctestrmn-dwcnt"
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

resource "azurerm_vpn_gateway_connection" "test" {
  name               = "acctest-VpnGwConn-231218072256498495"
  vpn_gateway_id     = azurerm_vpn_gateway.test.id
  remote_vpn_site_id = azurerm_vpn_site.test.id

  routing {
    associated_route_table = azurerm_virtual_hub.test.default_route_table_id
    inbound_route_map_id   = azurerm_route_map.test.id
    outbound_route_map_id  = azurerm_route_map.test2.id

    propagated_route_table {
      route_table_ids = [azurerm_virtual_hub.test.default_route_table_id]
      labels          = ["label1"]
    }
  }

  vpn_link {
    name             = "link1"
    vpn_site_link_id = azurerm_vpn_site.test.link[0].id

    ipsec_policy {
      sa_lifetime_sec          = 300
      sa_data_size_kb          = 1024
      encryption_algorithm     = "AES256"
      integrity_algorithm      = "SHA256"
      ike_encryption_algorithm = "AES128"
      ike_integrity_algorithm  = "SHA256"
      dh_group                 = "DHGroup14"
      pfs_group                = "PFS14"
    }

    bandwidth_mbps                        = 30
    protocol                              = "IKEv2"
    ratelimit_enabled                     = true
    route_weight                          = 2
    shared_key                            = "secret"
    local_azure_ip_address_enabled        = true
    policy_based_traffic_selector_enabled = true
  }

  vpn_link {
    name             = "link3"
    vpn_site_link_id = azurerm_vpn_site.test.link[1].id
  }
}
