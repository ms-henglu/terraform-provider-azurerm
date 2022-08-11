
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220811053440937878"
  location = "West Europe"
}

resource "azurerm_public_ip" "test1" {
  name                = "test-ip-1-220811053440937878"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "test2" {
  name                = "test-ip-2-220811053440937878"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "test" {
  name                = "arm-test-loadbalancer-220811053440937878"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "fe1-220811053440937878"
    public_ip_address_id = azurerm_public_ip.test1.id
  }

  frontend_ip_configuration {
    name                 = "fe2-220811053440937878"
    public_ip_address_id = azurerm_public_ip.test2.id
  }
}

resource "azurerm_lb_backend_address_pool" "test" {
  loadbalancer_id = azurerm_lb.test.id
  name            = "be-220811053440937878"
}

resource "azurerm_lb_outbound_rule" "test" {
  loadbalancer_id         = azurerm_lb.test.id
  name                    = "OutboundRule-220811053440937878"
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.test.id

  frontend_ip_configuration {
    name = "fe1-220811053440937878"
  }
}

resource "azurerm_lb_outbound_rule" "test2" {
  loadbalancer_id         = azurerm_lb.test.id
  name                    = "OutboundRule-220811053440931973"
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.test.id

  frontend_ip_configuration {
    name = "fe2-220811053440937878"
  }
}
