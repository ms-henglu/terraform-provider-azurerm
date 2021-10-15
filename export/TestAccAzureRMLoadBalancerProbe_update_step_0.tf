
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014755929380"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "test-ip-211015014755929380"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "test" {
  name                = "arm-test-loadbalancer-211015014755929380"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  frontend_ip_configuration {
    name                 = "one-211015014755929380"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_lb_probe" "test" {
  resource_group_name = azurerm_resource_group.test.name
  loadbalancer_id     = azurerm_lb.test.id
  name                = "probe-211015014755929380"
  port                = 22
}

resource "azurerm_lb_probe" "test2" {
  resource_group_name = azurerm_resource_group.test.name
  loadbalancer_id     = azurerm_lb.test.id
  name                = "probe-211015014755927053"
  port                = 80
}
