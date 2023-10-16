
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lb-231016034145781885"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-231016034145781885"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-subnet-231016034145781885"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_lb" "test" {
  name                = "acctest-lb-231016034145781885"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "Internal"
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.2.7"
    subnet_id                     = azurerm_subnet.test.id
  }
}

resource "azurerm_lb_nat_rule" "test" {
  resource_group_name            = azurerm_resource_group.test.name
  loadbalancer_id                = azurerm_lb.test.id
  name                           = "NatRule-231016034145781885"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  idle_timeout_in_minutes        = 4
  enable_floating_ip             = false
  enable_tcp_reset               = false
  frontend_ip_configuration_name = azurerm_lb.test.frontend_ip_configuration.0.name
}
