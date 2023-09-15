


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lb-230915023640120794"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "test-ip-230915023640120794"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "test" {
  name                = "arm-test-loadbalancer-230915023640120794"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "one-230915023640120794"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-230915023640120794"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_lb_backend_address_pool" "test" {
  name            = "internal"
  loadbalancer_id = azurerm_lb.test.id
}

resource "azurerm_lb_backend_address_pool_address" "test" {
  name                    = "address"
  backend_address_pool_id = azurerm_lb_backend_address_pool.test.id
  virtual_network_id      = azurerm_virtual_network.test.id
  ip_address              = "191.168.0.1"
}

resource "azurerm_lb_nat_rule" "test" {
  name                = "NatRule-230915023640120794"
  resource_group_name = "${azurerm_resource_group.test.name}"
  loadbalancer_id     = "${azurerm_lb.test.id}"

  protocol                = "Tcp"
  frontend_port_start     = 3000
  frontend_port_end       = 3389
  backend_port            = 3389
  backend_address_pool_id = azurerm_lb_backend_address_pool.test.id

  frontend_ip_configuration_name = azurerm_lb.test.frontend_ip_configuration.0.name
}

resource "azurerm_lb_nat_rule" "test1" {
  name                = "NatRule2-230915023640120794"
  resource_group_name = "${azurerm_resource_group.test.name}"
  loadbalancer_id     = "${azurerm_lb.test.id}"

  protocol                = "Udp"
  frontend_port_start     = 3000
  frontend_port_end       = 3389
  backend_port            = 3389
  backend_address_pool_id = azurerm_lb_backend_address_pool.test.id

  frontend_ip_configuration_name = azurerm_lb.test.frontend_ip_configuration.0.name
}
