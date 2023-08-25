
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vnetgwconn-230825025022054633"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-230825025022054633"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctestip-230825025022054633"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_network_gateway" "test" {
  name                = "acctestgw-230825025022054633"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  type                       = "Vpn"
  vpn_type                   = "RouteBased"
  enable_bgp                 = true
  active_active              = false
  private_ip_address_enabled = false
  sku                        = "VpnGw2"
  generation                 = "Generation2"

  ip_configuration {
    name                          = "default"
    public_ip_address_id          = azurerm_public_ip.test.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.test.id
  }

  bgp_settings {
    asn = "65000"

    peering_addresses {
      ip_configuration_name = "default"
      apipa_addresses = [
        "169.254.21.2",
        "169.254.22.2"
      ]
    }
  }
}

resource "azurerm_local_network_gateway" "test" {
  name                = "acctestlgw-230825025022054633"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  gateway_address = "168.62.225.23"

  bgp_settings {
    asn                 = "64512"
    bgp_peering_address = "169.254.21.1"
  }
}

resource "azurerm_virtual_network_gateway_connection" "test" {
  name                           = "acctestgwc-230825025022054633"
  location                       = azurerm_resource_group.test.location
  resource_group_name            = azurerm_resource_group.test.name
  local_azure_ip_address_enabled = false

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.test.id
  local_network_gateway_id   = azurerm_local_network_gateway.test.id
  dpd_timeout_seconds        = 30

  shared_key = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"

  enable_bgp = true

  custom_bgp_addresses {
    primary = "169.254.21.2"
  }
}
