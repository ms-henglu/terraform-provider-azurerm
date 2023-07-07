

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707010742352767"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-230707010742352767"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
}

resource "azurerm_subnet" "test" {
  name                                          = "subnet-230707010742352767"
  resource_group_name                           = azurerm_resource_group.test.name
  virtual_network_name                          = azurerm_virtual_network.test.name
  address_prefixes                              = ["10.0.0.0/24"]
  enforce_private_link_service_network_policies = true
}

resource "azurerm_public_ip" "test" {
  name                = "acctest-pubip-230707010742352767"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
}


# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name               = "${azurerm_virtual_network.test.name}-beap"
  frontend_port_name                      = "${azurerm_virtual_network.test.name}-feport"
  frontend_ip_configuration_name          = "${azurerm_virtual_network.test.name}-feip"
  frontend_ip_configuration_internal_name = "${azurerm_virtual_network.test.name}-feipint"
  http_setting_name                       = "${azurerm_virtual_network.test.name}-be-htst"
  listener_name                           = "${azurerm_virtual_network.test.name}-httplstn"
  request_routing_rule_name               = "${azurerm_virtual_network.test.name}-rqrt"
  private_link_configuration_name         = "private_link"
}

resource "azurerm_public_ip" "test_standard" {
  name                = "acctest-pubip-standard-230707010742352767"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "test" {
  name                = "acctestag-230707010742352767"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.test.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.test_standard.id
  }

  frontend_ip_configuration {
    name                            = local.frontend_ip_configuration_internal_name
    subnet_id                       = azurerm_subnet.test.id
    private_ip_address_allocation   = "Static"
    private_ip_address              = "10.0.0.10"
    private_link_configuration_name = local.private_link_configuration_name
  }

  private_link_configuration {
    name = local.private_link_configuration_name
    ip_configuration {
      name                          = "primary"
      subnet_id                     = azurerm_subnet.test.id
      private_ip_address_allocation = "Dynamic"
      primary                       = true
    }
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 10
  }
}
