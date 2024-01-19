

locals {
  vm_name = "acctvm24"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024707497229"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119024707497229"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}


locals {
  frontend_ip_configuration_name = "internal"
}

resource "azurerm_public_ip" "test" {
  name                = "actestvmsspip-240119024707497229"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  allocation_method   = "Static"
}

resource "azurerm_lb" "test" {
  name                = "actestvmsslb-240119024707497229"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_lb_backend_address_pool" "test" {
  name            = "backend"
  loadbalancer_id = azurerm_lb.test.id
}

resource "azurerm_lb_probe" "test" {
  name            = "ssh-running-probe"
  loadbalancer_id = azurerm_lb.test.id
  port            = 3389
  protocol        = "Tcp"
}

resource "azurerm_lb_probe" "test2" {
  name            = "ssh-running-probe2"
  loadbalancer_id = azurerm_lb.test.id
  port            = 3389
  protocol        = "Tcp"
}

resource "azurerm_lb_rule" "test" {
  loadbalancer_id                = azurerm_lb.test.id
  probe_id                       = azurerm_lb_probe.test.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.test.id]
  frontend_ip_configuration_name = local.frontend_ip_configuration_name
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
}

resource "azurerm_windows_virtual_machine_scale_set" "test" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_F2"
  instances           = 3
  admin_username      = "adminuser"
  admin_password      = "P@ssword1234!"

  upgrade_mode    = "Automatic"
  health_probe_id = azurerm_lb_probe.test.id

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name                                   = "internal"
      subnet_id                              = azurerm_subnet.test.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.test.id]
      primary                                = true
    }
  }

  depends_on = [azurerm_lb_rule.test]
}
