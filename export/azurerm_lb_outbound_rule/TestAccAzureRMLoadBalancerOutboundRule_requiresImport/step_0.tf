
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025245710598"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "test-ip-240119025245710598"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "test" {
  name                = "arm-test-loadbalancer-240119025245710598"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "one-240119025245710598"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_lb_backend_address_pool" "test" {
  loadbalancer_id = azurerm_lb.test.id
  name            = "be-240119025245710598"
}

resource "azurerm_lb_outbound_rule" "test" {
  loadbalancer_id         = azurerm_lb.test.id
  name                    = "OutboundRule-240119025245710598"
  backend_address_pool_id = azurerm_lb_backend_address_pool.test.id
  protocol                = "All"

  frontend_ip_configuration {
    name = "one-240119025245710598"
  }
}
