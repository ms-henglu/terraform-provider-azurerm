

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vpn-231020041557369375"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctest-vwan-231020041557369375"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctest-vhub-231020041557369375"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_prefix      = "10.0.0.0/24"
}

resource "azurerm_vpn_gateway" "test" {
  name                = "acctest-vpngw-231020041557369375"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  virtual_hub_id      = azurerm_virtual_hub.test.id
}

resource "azurerm_vpn_site" "test" {
  name                = "acctest-vpnsite-231020041557369375"
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


resource "azurerm_vpn_gateway_nat_rule" "test" {
  name                            = "acctest-vpngwnatrule-231020041557369375"
  resource_group_name             = azurerm_resource_group.test.name
  vpn_gateway_id                  = azurerm_vpn_gateway.test.id
  external_address_space_mappings = ["192.168.21.0/26"]
  internal_address_space_mappings = ["10.4.0.0/26"]
  mode                            = "EgressSnat"
  type                            = "Static"
}

resource "azurerm_vpn_gateway_nat_rule" "test2" {
  name                            = "acctest-vpngwnatrule2-231020041557369375"
  resource_group_name             = azurerm_resource_group.test.name
  vpn_gateway_id                  = azurerm_vpn_gateway.test.id
  external_address_space_mappings = ["192.168.22.0/26"]
  internal_address_space_mappings = ["10.5.0.0/26"]
  mode                            = "IngressSnat"
  type                            = "Static"
}

resource "azurerm_vpn_gateway_connection" "test" {
  name               = "acctest-VpnGwConn-231020041557369375"
  vpn_gateway_id     = azurerm_vpn_gateway.test.id
  remote_vpn_site_id = azurerm_vpn_site.test.id

  vpn_link {
    name                = "link1"
    vpn_site_link_id    = azurerm_vpn_site.test.link[0].id
    egress_nat_rule_ids = [azurerm_vpn_gateway_nat_rule.test.id]
  }

  vpn_link {
    name                 = "link2"
    vpn_site_link_id     = azurerm_vpn_site.test.link[1].id
    ingress_nat_rule_ids = [azurerm_vpn_gateway_nat_rule.test2.id]
  }

  lifecycle {
    create_before_destroy = true
  }
}
