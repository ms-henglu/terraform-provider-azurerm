
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630033418863219"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "test-ip-230630033418863219"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "test" {
  name                = "arm-test-loadbalancer-230630033418863219"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  frontend_ip_configuration {
    name                 = "one-230630033418863219"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_lb_probe" "test" {
  loadbalancer_id     = azurerm_lb.test.id
  name                = "probe-230630033418863219"
  port                = 22
  interval_in_seconds = 5
  number_of_probes    = 2
  probe_threshold     = 2
}
