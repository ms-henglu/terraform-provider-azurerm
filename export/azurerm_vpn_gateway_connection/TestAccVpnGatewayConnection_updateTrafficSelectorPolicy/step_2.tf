

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vpn-221124182052995357"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctest-vwan-221124182052995357"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctest-vhub-221124182052995357"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_prefix      = "10.0.0.0/24"
}

resource "azurerm_vpn_gateway" "test" {
  name                = "acctest-vpngw-221124182052995357"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  virtual_hub_id      = azurerm_virtual_hub.test.id
}

resource "azurerm_vpn_site" "test" {
  name                = "acctest-vpnsite-221124182052995357"
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


resource "azurerm_vpn_gateway_connection" "test" {
  name               = "acctest-VpnGwConn-221124182052995357"
  vpn_gateway_id     = azurerm_vpn_gateway.test.id
  remote_vpn_site_id = azurerm_vpn_site.test.id
  vpn_link {
    name             = "link1"
    vpn_site_link_id = azurerm_vpn_site.test.link[0].id
  }
  vpn_link {
    name             = "link2"
    vpn_site_link_id = azurerm_vpn_site.test.link[1].id
  }
  traffic_selector_policy {
    local_address_ranges  = ["10.0.0.0/24"]
    remote_address_ranges = ["10.0.1.0/24"]
  }
}
