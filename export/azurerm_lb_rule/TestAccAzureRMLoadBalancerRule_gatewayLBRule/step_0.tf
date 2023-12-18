

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072018581618"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet-231218072018581618"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet-231218072018581618"
  resource_group_name  = azurerm_virtual_network.test.resource_group_name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_lb" "test" {
  name                = "acctestlb-231218072018581618"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Gateway"

  frontend_ip_configuration {
    name      = "feip"
    subnet_id = azurerm_subnet.test.id
  }
}

resource "azurerm_public_ip" "c1" {
  name                = "acctestpip1-231218072018581618"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_lb" "c1" {
  name                = "acctestlb-consumer1-231218072018581618"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                                               = "gateway"
    public_ip_address_id                               = azurerm_public_ip.c1.id
    gateway_load_balancer_frontend_ip_configuration_id = azurerm_lb.test.frontend_ip_configuration.0.id
  }
}

resource "azurerm_public_ip" "c2" {
  name                = "acctestpip2-231218072018581618"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_lb" "c2" {
  name                = "acctestlb-consumer2-231218072018581618"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                                               = "gateway"
    public_ip_address_id                               = azurerm_public_ip.c2.id
    gateway_load_balancer_frontend_ip_configuration_id = azurerm_lb.test.frontend_ip_configuration.0.id
  }
}


resource "azurerm_lb_backend_address_pool" "test" {
  name            = "acctestbap-231218072018581618"
  loadbalancer_id = azurerm_lb.test.id
  tunnel_interface {
    identifier = 900
    type       = "Internal"
    protocol   = "VXLAN"
    port       = 15000
  }
  tunnel_interface {
    identifier = 901
    type       = "External"
    protocol   = "VXLAN"
    port       = 15001
  }
}

resource "azurerm_lb_rule" "test" {
  loadbalancer_id = azurerm_lb.test.id
  name            = "abababa"
  protocol        = "All"
  frontend_port   = 0
  backend_port    = 0
  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.test.id,
  ]
  frontend_ip_configuration_name = azurerm_lb.test.frontend_ip_configuration.0.name
}
