
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922054621793260"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestVWAN-230922054621793260"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctestVHUB-230922054621793260"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_prefix      = "10.0.0.0/24"
}

resource "azurerm_vpn_gateway" "test" {
  name                = "acctestVPNGW-230922054621793260"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  virtual_hub_id      = azurerm_virtual_hub.test.id

  bgp_settings {
    asn         = 65515
    peer_weight = 0

    instance_0_bgp_peering_address {
      custom_ips = ["169.254.21.5"]
    }

    instance_1_bgp_peering_address {
      custom_ips = ["169.254.21.10"]
    }
  }
}

resource "azurerm_vpn_site" "test" {
  name                = "acctestVPNSite-230922054621793260"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  virtual_wan_id      = azurerm_virtual_wan.test.id

  link {
    name       = "link1"
    ip_address = "169.254.21.5"

    bgp {
      asn             = 1234
      peering_address = "169.254.21.5"
    }
  }
}

resource "azurerm_vpn_gateway_connection" "test" {
  name               = "acctestVPNGWConn-230922054621793260"
  vpn_gateway_id     = azurerm_vpn_gateway.test.id
  remote_vpn_site_id = azurerm_vpn_site.test.id

  vpn_link {
    name             = "link1"
    vpn_site_link_id = azurerm_vpn_site.test.link[0].id
    bgp_enabled      = true

    custom_bgp_address {
      ip_address          = "169.254.21.5"
      ip_configuration_id = azurerm_vpn_gateway.test.bgp_settings.0.instance_0_bgp_peering_address.0.ip_configuration_id
    }

    custom_bgp_address {
      ip_address          = "169.254.21.10"
      ip_configuration_id = azurerm_vpn_gateway.test.bgp_settings.0.instance_1_bgp_peering_address.0.ip_configuration_id
    }
  }
}
