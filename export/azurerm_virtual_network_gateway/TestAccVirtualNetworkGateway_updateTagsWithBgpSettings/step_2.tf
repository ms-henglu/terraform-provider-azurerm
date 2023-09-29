
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ngw-230929065415027492"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-230929065415027492"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "first" {
  name                = "acctestpip1-230929065415027492"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
}

resource "azurerm_public_ip" "second" {
  name = "acctestpip2-230929065415027492"

  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "test" {
  depends_on = [
    azurerm_public_ip.first,
    azurerm_public_ip.second,
  ]
  name                = "acctestvng-230929065415027492"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = "VpnGw1"

  active_active = true
  enable_bgp    = true

  ip_configuration {
    name                 = "gw-ip1"
    public_ip_address_id = azurerm_public_ip.first.id

    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.test.id
  }

  ip_configuration {
    name                          = "gw-ip2"
    public_ip_address_id          = azurerm_public_ip.second.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.test.id
  }

  bgp_settings {
    asn = "65010"
    peering_addresses {
      ip_configuration_name = "gw-ip1"
      apipa_addresses       = ["169.254.21.1"]
    }
    peering_addresses {
      ip_configuration_name = "gw-ip2"
      apipa_addresses       = ["169.254.21.2"]
    }
  }

  tags = {
    env = "Test"
  }
}
