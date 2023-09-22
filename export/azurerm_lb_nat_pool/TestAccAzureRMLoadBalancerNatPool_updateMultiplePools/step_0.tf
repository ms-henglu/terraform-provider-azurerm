
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922061350283231"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "test-ip-230922061350283231"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  allocation_method = "Static"
}

resource "azurerm_lb" "test" {
  name                = "arm-test-loadbalancer-230922061350283231"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  frontend_ip_configuration {
    name                 = "one-230922061350283231"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_lb_nat_pool" "test" {
  resource_group_name = azurerm_resource_group.test.name
  loadbalancer_id     = azurerm_lb.test.id
  name                = "NatPool-230922061350283231"
  protocol            = "Tcp"
  frontend_port_start = 80
  frontend_port_end   = 81
  backend_port        = 3389

  frontend_ip_configuration_name = "one-230922061350283231"
}

resource "azurerm_lb_nat_pool" "test2" {
  resource_group_name = azurerm_resource_group.test.name
  loadbalancer_id     = azurerm_lb.test.id
  name                = "NatPool-230922061350282168"
  protocol            = "Tcp"
  frontend_port_start = 82
  frontend_port_end   = 83
  backend_port        = 3390

  frontend_ip_configuration_name = "one-230922061350283231"
}
