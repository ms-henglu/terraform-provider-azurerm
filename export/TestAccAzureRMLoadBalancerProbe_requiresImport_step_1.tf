

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924011131055991"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "test-ip-210924011131055991"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "test" {
  name                = "arm-test-loadbalancer-210924011131055991"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  frontend_ip_configuration {
    name                 = "one-210924011131055991"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_lb_probe" "test" {
  resource_group_name = azurerm_resource_group.test.name
  loadbalancer_id     = azurerm_lb.test.id
  name                = "probe-210924011131055991"
  port                = 22
}


resource "azurerm_lb_probe" "import" {
  name                = azurerm_lb_probe.test.name
  loadbalancer_id     = azurerm_lb_probe.test.loadbalancer_id
  resource_group_name = azurerm_lb_probe.test.resource_group_name
  port                = 22
}
