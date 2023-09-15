
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023640128672"
  location = "West Europe"
}
resource "azurerm_public_ip" "test" {
  name                = "test-ip-230915023640128672"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_lb" "test" {
  name                = "arm-test-loadbalancer-230915023640128672"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "one-230915023640128672"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}
resource "azurerm_lb_nat_pool" "test" {
  resource_group_name            = azurerm_resource_group.test.name
  loadbalancer_id                = azurerm_lb.test.id
  name                           = "NatPool-230915023640128672"
  protocol                       = "Tcp"
  frontend_port_start            = 80
  frontend_port_end              = 81
  backend_port                   = 3389
  frontend_ip_configuration_name = "one-230915023640128672"
  floating_ip_enabled            = true
  tcp_reset_enabled              = true
  idle_timeout_in_minutes        = 10
}
