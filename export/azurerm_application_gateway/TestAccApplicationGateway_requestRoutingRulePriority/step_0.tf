

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311032742143956"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-240311032742143956"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
}

resource "azurerm_subnet" "test" {
  name                                          = "subnet-240311032742143956"
  resource_group_name                           = azurerm_resource_group.test.name
  virtual_network_name                          = azurerm_virtual_network.test.name
  address_prefixes                              = ["10.0.0.0/24"]
  enforce_private_link_service_network_policies = true
}

resource "azurerm_public_ip" "test" {
  name                = "acctest-pubip-240311032742143956"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
}


# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.test.name}-beap"
  frontend_port_name_1           = "${azurerm_virtual_network.test.name}-feport-1"
  frontend_port_name_2           = "${azurerm_virtual_network.test.name}-feport-2"
  frontend_ip_configuration_name = "${azurerm_virtual_network.test.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.test.name}-be-htst"
  listener_name_1                = "${azurerm_virtual_network.test.name}-httplstn-1"
  listener_name_2                = "${azurerm_virtual_network.test.name}-httplstn-2"
  request_routing_rule_name_1    = "${azurerm_virtual_network.test.name}-rqrt-1"
  request_routing_rule_name_2    = "${azurerm_virtual_network.test.name}-rqrt-2"
}

resource "azurerm_public_ip" "test_standard" {
  name                = "acctest-pubip-240311032742143956-standard"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_application_gateway" "test" {
  name                = "acctestag-240311032742143956"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  ssl_policy {
    policy_type          = "Custom"
    min_protocol_version = "TLSv1_1"
    cipher_suites        = ["TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384", "TLS_RSA_WITH_AES_128_GCM_SHA256"]
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.test.id
  }

  frontend_port {
    name = local.frontend_port_name_1
    port = 80
  }

  frontend_port {
    name = local.frontend_port_name_2
    port = 8080
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.test_standard.id
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
    name                           = local.listener_name_1
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name_1
    protocol                       = "Http"
  }

  http_listener {
    name                           = local.listener_name_2
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name_2
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name_1
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name_1
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 1
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name_2
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name_2
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 20000
  }
}
