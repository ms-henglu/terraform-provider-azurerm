

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lb-221111020704301859"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "test-ip-221111020704301859"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

resource "azurerm_lb" "test" {
  name                = "arm-test-loadbalancer-221111020704301859"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"

  frontend_ip_configuration {
    name                 = "one-221111020704301859"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}


resource "azurerm_lb_backend_address_pool" "test" {
  name            = "221111020704301859-address-pool"
  loadbalancer_id = azurerm_lb.test.id
}

resource "azurerm_lb_probe" "test" {
  name            = "probe-221111020704301859"
  loadbalancer_id = azurerm_lb.test.id
  protocol        = "Tcp"
  port            = 443
}

resource "azurerm_lb_rule" "test" {
  name                           = "LbRule-flu12att"
  loadbalancer_id                = azurerm_lb.test.id
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = azurerm_lb.test.frontend_ip_configuration.0.name
}
