

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210830084128037510"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "test-ip-210830084128037510"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "test" {
  name                = "arm-test-loadbalancer-210830084128037510"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "one-210830084128037510"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_lb_backend_address_pool" "test" {
  resource_group_name = azurerm_resource_group.test.name
  loadbalancer_id     = azurerm_lb.test.id
  name                = "be-210830084128037510"
}

resource "azurerm_lb_outbound_rule" "test" {
  resource_group_name     = azurerm_resource_group.test.name
  loadbalancer_id         = azurerm_lb.test.id
  name                    = "OutboundRule-210830084128037510"
  backend_address_pool_id = azurerm_lb_backend_address_pool.test.id
  protocol                = "All"

  frontend_ip_configuration {
    name = "one-210830084128037510"
  }
}


resource "azurerm_lb_outbound_rule" "import" {
  name                    = azurerm_lb_outbound_rule.test.name
  resource_group_name     = azurerm_lb_outbound_rule.test.resource_group_name
  loadbalancer_id         = azurerm_lb_outbound_rule.test.loadbalancer_id
  backend_address_pool_id = azurerm_lb_backend_address_pool.test.id
  protocol                = "All"

  frontend_ip_configuration {
    name = azurerm_lb_outbound_rule.test.frontend_ip_configuration[0].name
  }
}
