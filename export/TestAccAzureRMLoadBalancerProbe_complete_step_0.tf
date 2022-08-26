
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826002910147707"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "test-ip-220826002910147707"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "test" {
  name                = "arm-test-loadbalancer-220826002910147707"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  frontend_ip_configuration {
    name                 = "one-220826002910147707"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_lb_probe" "test" {
  loadbalancer_id     = azurerm_lb.test.id
  name                = "probe-220826002910147707"
  port                = 22
  interval_in_seconds = 5
  number_of_probes    = 2
}
