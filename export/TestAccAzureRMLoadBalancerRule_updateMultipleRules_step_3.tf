

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lb-220324163527892066"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "test-ip-220324163527892066"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

resource "azurerm_lb" "test" {
  name                = "arm-test-loadbalancer-220324163527892066"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"

  frontend_ip_configuration {
    name                 = "one-220324163527892066"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}


resource "azurerm_lb_rule" "test" {
  loadbalancer_id                = azurerm_lb.test.id
  name                           = "LbRule-2kl3fdkk"
  protocol                       = "Udp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = azurerm_lb.test.frontend_ip_configuration.0.name
}

resource "azurerm_lb_rule" "test2" {
  loadbalancer_id                = azurerm_lb.test.id
  name                           = "LbRule-avgsxx7r"
  protocol                       = "Udp"
  frontend_port                  = 3391
  backend_port                   = 3391
  frontend_ip_configuration_name = azurerm_lb.test.frontend_ip_configuration.0.name
}
