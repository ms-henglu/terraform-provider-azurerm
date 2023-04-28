

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428050246977097"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-230428050246977097"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_virtual_network" "gateway" {
  name                = "acctestvnet-gw-230428050246977097"
  address_space       = ["11.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "gateway" {
  name                 = "acctestsubnet-gw-230428050246977097"
  resource_group_name  = azurerm_virtual_network.gateway.resource_group_name
  virtual_network_name = azurerm_virtual_network.gateway.name
  address_prefixes     = ["11.0.2.0/24"]
}

resource "azurerm_lb" "gateway" {
  name                = "acctestlb-230428050246977097"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Gateway"

  frontend_ip_configuration {
    name      = "feip"
    subnet_id = azurerm_subnet.gateway.id
  }
}

resource "azurerm_lb_backend_address_pool" "gateway" {
  name            = "acctestbap-230428050246977097"
  loadbalancer_id = azurerm_lb.gateway.id
  tunnel_interface {
    identifier = 900
    type       = "Internal"
    protocol   = "VXLAN"
    port       = 15000
  }
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-230428050246977097"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230428050246977097"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                                               = "gateway"
    public_ip_address_id                               = azurerm_public_ip.test.id
    gateway_load_balancer_frontend_ip_configuration_id = azurerm_lb.gateway.frontend_ip_configuration.0.id
    private_ip_address_allocation                      = "Dynamic"
    subnet_id                                          = azurerm_subnet.test.id
  }
}
