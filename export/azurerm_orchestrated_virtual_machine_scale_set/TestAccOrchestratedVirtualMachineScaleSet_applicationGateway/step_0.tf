
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-OVMSS-240119021734528442"
  location = "West Europe"
}


resource "azurerm_public_ip" "test" {
  name                = "acctpip-240119021734528442"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctvn-240119021734528442"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctsub-240119021734528442"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_nat_gateway" "test" {
  name                    = "acctng-240119021734528442"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

resource "azurerm_nat_gateway_public_ip_association" "test" {
  nat_gateway_id       = azurerm_nat_gateway.test.id
  public_ip_address_id = azurerm_public_ip.test.id
}

resource "azurerm_subnet_nat_gateway_association" "example" {
  subnet_id      = azurerm_subnet.test.id
  nat_gateway_id = azurerm_nat_gateway.test.id
}


resource "azurerm_orchestrated_virtual_machine_scale_set" "test" {
  name                = "acctestOVMSS-240119021734528442"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name  = "Standard_D1_v2"
  instances = 1

  platform_fault_domain_count = 2

  os_profile {
    linux_configuration {
      computer_name_prefix = "testvm-240119021734528442"
      admin_username       = "myadmin"
      admin_password       = "Passwword1234"

      disable_password_authentication = false
    }
  }

  network_interface {
    name    = "TestNetworkProfile"
    primary = true

    ip_configuration {
      name      = "TestPublicIPConfiguration"
      primary   = true
      subnet_id = azurerm_subnet.test.id

      application_gateway_backend_address_pool_ids = [tolist(azurerm_application_gateway.test.backend_address_pool)[0].id]
    }
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# application gateway
resource "azurerm_subnet" "gwtest" {
  name                 = "gw-subnet-240119021734528442"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_public_ip" "gwtest" {
  name                = "acctest-pubip-240119021734528442"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
}

resource "azurerm_application_gateway" "test" {
  name                = "acctestgw-240119021734528442"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Standard_Medium"
    tier     = "Standard"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "gw-ip-config1"
    subnet_id = azurerm_subnet.gwtest.id
  }

  frontend_ip_configuration {
    name                 = "ip-config-public"
    public_ip_address_id = azurerm_public_ip.gwtest.id
  }

  frontend_ip_configuration {
    name      = "ip-config-private"
    subnet_id = azurerm_subnet.gwtest.id

    private_ip_address_allocation = "Dynamic"
  }

  frontend_port {
    name = "port-8080"
    port = 8080
  }

  backend_address_pool {
    name = "pool-1"
  }

  backend_http_settings {
    name                  = "backend-http-1"
    port                  = 8010
    protocol              = "Http"
    cookie_based_affinity = "Enabled"
    request_timeout       = 30

    probe_name = "probe-1"
  }

  http_listener {
    name                           = "listener-1"
    frontend_ip_configuration_name = "ip-config-public"
    frontend_port_name             = "port-8080"
    protocol                       = "Http"
  }

  probe {
    name                = "probe-1"
    protocol            = "Http"
    path                = "/test"
    host                = "azure.com"
    timeout             = 120
    interval            = 300
    unhealthy_threshold = 8
  }

  request_routing_rule {
    name                       = "rule-basic-1"
    rule_type                  = "Basic"
    http_listener_name         = "listener-1"
    backend_address_pool_name  = "pool-1"
    backend_http_settings_name = "backend-http-1"
  }

  tags = {
    environment = "tf01"
  }
}
