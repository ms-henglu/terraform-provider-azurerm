
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230120052227707165"
  location = "West Europe"
}

resource "azurerm_public_ip" "test1" {
  name                = "test-ip-1-230120052227707165"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "test2" {
  name                = "test-ip-2-230120052227707165"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "test" {
  name                = "arm-test-loadbalancer-230120052227707165"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "fe1-230120052227707165"
    public_ip_address_id = azurerm_public_ip.test1.id
  }

  frontend_ip_configuration {
    name                 = "fe2-230120052227707165"
    public_ip_address_id = azurerm_public_ip.test2.id
  }
}

resource "azurerm_lb_backend_address_pool" "test" {
  loadbalancer_id = azurerm_lb.test.id
  name            = "be-230120052227707165"
}

resource "azurerm_lb_outbound_rule" "test" {
  loadbalancer_id         = azurerm_lb.test.id
  name                    = "OutboundRule-230120052227707165"
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.test.id

  frontend_ip_configuration {
    name = "fe1-230120052227707165"
  }
}

resource "azurerm_lb_outbound_rule" "test2" {
  loadbalancer_id         = azurerm_lb.test.id
  name                    = "OutboundRule-230120052227707378"
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.test.id

  frontend_ip_configuration {
    name = "fe2-230120052227707165"
  }
}
