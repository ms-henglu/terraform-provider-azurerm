
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230120052227711062"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "test-ip-230120052227711062"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "test" {
  name                = "arm-test-loadbalancer-230120052227711062"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  frontend_ip_configuration {
    name                 = "one-230120052227711062"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_lb_probe" "test" {
  loadbalancer_id = azurerm_lb.test.id
  name            = "probe-230120052227711062"
  port            = 22
}

resource "azurerm_lb_probe" "test2" {
  loadbalancer_id = azurerm_lb.test.id
  name            = "probe-230120052227711106"
  port            = 8080
}
