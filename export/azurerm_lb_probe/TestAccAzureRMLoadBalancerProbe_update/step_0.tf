
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613072110635843"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "test-ip-230613072110635843"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "test" {
  name                = "arm-test-loadbalancer-230613072110635843"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  frontend_ip_configuration {
    name                 = "one-230613072110635843"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_lb_probe" "test" {
  loadbalancer_id = azurerm_lb.test.id
  name            = "probe-230613072110635843"
  port            = 22
  probe_threshold = 2
}

resource "azurerm_lb_probe" "test2" {
  loadbalancer_id = azurerm_lb.test.id
  name            = "probe-230613072110634242"
  port            = 80
  probe_threshold = 3
}
