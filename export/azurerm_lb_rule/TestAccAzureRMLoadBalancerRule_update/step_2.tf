

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lb-230526085334021539"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "test-ip-230526085334021539"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "test" {
  name                = "arm-test-loadbalancer-230526085334021539"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "one-230526085334021539"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}


resource "azurerm_lb_rule" "test" {
  name            = "LbRule-0dzwaryx"
  loadbalancer_id = azurerm_lb.test.id

  protocol      = "Tcp"
  frontend_port = 3389
  backend_port  = 3389

  disable_outbound_snat   = true
  enable_floating_ip      = true
  enable_tcp_reset        = true
  idle_timeout_in_minutes = 10
  load_distribution       = "SourceIP"

  frontend_ip_configuration_name = azurerm_lb.test.frontend_ip_configuration.0.name
}
