
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014755917503"
  location = "West Europe"
}

resource "azurerm_public_ip_prefix" "test" {
  name                = "test-ip-211015014755917503"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  prefix_length       = 31
}

resource "azurerm_lb" "test" {
  name                = "arm-test-loadbalancer-211015014755917503"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                = "one-211015014755917503"
    public_ip_prefix_id = azurerm_public_ip_prefix.test.id
  }
}

resource "azurerm_lb_backend_address_pool" "test" {
  resource_group_name = azurerm_resource_group.test.name
  loadbalancer_id     = azurerm_lb.test.id
  name                = "be-211015014755917503"
}

resource "azurerm_lb_outbound_rule" "test" {
  resource_group_name     = azurerm_resource_group.test.name
  loadbalancer_id         = azurerm_lb.test.id
  name                    = "OutboundRule-211015014755917503"
  backend_address_pool_id = azurerm_lb_backend_address_pool.test.id
  protocol                = "All"

  frontend_ip_configuration {
    name = "one-211015014755917503"
  }
}
