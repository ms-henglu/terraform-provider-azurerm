
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311032406996252"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet-240311032406996252"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet-240311032406996252"
  resource_group_name  = azurerm_virtual_network.test.resource_group_name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_lb" "test" {
  name                = "acctestlb-240311032406996252"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Gateway"

  frontend_ip_configuration {
    name      = "feip"
    subnet_id = azurerm_subnet.test.id
  }
}


resource "azurerm_lb_backend_address_pool" "test" {
  name            = "acctestbap-240311032406996252"
  loadbalancer_id = azurerm_lb.test.id
  tunnel_interface {
    identifier = 900
    type       = "Internal"
    protocol   = "VXLAN"
    port       = 15000
  }
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-240311032406996252"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_lb" "consumer" {
  name                = "acctestlb-consumer-240311032406996252"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                                               = "gateway"
    public_ip_address_id                               = azurerm_public_ip.test.id
    gateway_load_balancer_frontend_ip_configuration_id = azurerm_lb.test.frontend_ip_configuration.0.id
  }
}
