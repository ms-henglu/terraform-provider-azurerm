
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230915023140736566"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet230915023140736566"
  address_space       = ["172.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet230915023140736566"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["172.0.2.0/24"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip230915023140736566"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_application_gateway" "test" {
  name                = "acctestappgw230915023140736566"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gwipcfg"
    subnet_id = azurerm_subnet.test.id
  }

  frontend_port {
    name = "frontendport"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontendipcfg"
    public_ip_address_id = azurerm_public_ip.test.id
  }

  backend_address_pool {
    name = "backendaddresspool"
  }

  backend_http_settings {
    name                  = "backendhttpsettings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "httplistener"
    frontend_ip_configuration_name = "frontendipcfg"
    frontend_port_name             = "frontendport"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "requestroutingrule"
    rule_type                  = "Basic"
    http_listener_name         = "httplistener"
    backend_address_pool_name  = "backendaddresspool"
    backend_http_settings_name = "backendhttpsettings"
    priority                   = 1
  }
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230915023140736566"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230915023140736566"

  linux_profile {
    admin_username = "acctestuser230915023140736566"

    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqaZoyiz1qbdOQ8xEf6uEu1cCwYowo5FHtsBhqLoDnnp7KUTEBN+L2NxRIfQ781rxV6Iq5jSav6b2Q8z5KiseOlvKA/RF2wqU0UPYqQviQhLmW6THTpmrv/YkUCuzxDpsH7DUDhZcwySLKVVe0Qm3+5N2Ta6UYH3lsDf9R9wTP2K/+vAnflKebuypNlmocIvakFWoZda18FOmsOoIVXQ8HWFNCuw9ZCunMSN62QGamCe3dL5cXlkgHYv7ekJE15IA9aOJcM7e90oeTqo+7HTcWfdu0qQqPWY5ujyMw/llas8tsXY85LFqRnr3gJ02bAscjc477+X+j/gkpFoN1QEmt terraform@demo.tld"
    }
  }

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.test.id
  }

  identity {
    type = "SystemAssigned"
  }
}
