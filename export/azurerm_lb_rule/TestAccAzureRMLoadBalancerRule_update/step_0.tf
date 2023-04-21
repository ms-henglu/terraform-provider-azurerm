

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lb-230421022409167322"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "test-ip-230421022409167322"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

resource "azurerm_lb" "test" {
  name                = "arm-test-loadbalancer-230421022409167322"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"

  frontend_ip_configuration {
    name                 = "one-230421022409167322"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}


resource "azurerm_lb_rule" "test" {
  name                           = "LbRule-untf2qnq"
  loadbalancer_id                = azurerm_lb.test.id
  frontend_ip_configuration_name = azurerm_lb.test.frontend_ip_configuration.0.name
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
}
