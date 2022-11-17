
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221117231050312685"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "test-ip-221117231050312685"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "test" {
  name                = "arm-test-loadbalancer-221117231050312685"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  frontend_ip_configuration {
    name                 = "one-221117231050312685"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_lb_probe" "test" {
  loadbalancer_id = azurerm_lb.test.id
  name            = "probe-221117231050312685"
  protocol        = "Http"
  request_path    = "/"
  port            = 80
}
