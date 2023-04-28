

locals {
  vm_name = "acctvm23"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428045412317989"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230428045412317989"
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

resource "azurerm_lb" "test" {
  name                = "actestvmsslb-230428045412317989"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name      = local.frontend_ip_configuration_name
    subnet_id = azurerm_subnet.test.id
    zones     = ["1"]
  }
}

resource "azurerm_lb_backend_address_pool" "test" {
  name            = "backend"
  loadbalancer_id = azurerm_lb.test.id
}

resource "azurerm_lb_probe" "test" {
  name            = "running-probe"
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
  frontend_port                  = 389
  backend_port                   = 389
}

resource "azurerm_windows_virtual_machine_scale_set" "test" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_F2"
  instances           = 3
  admin_username      = "adminuser"
  admin_password      = "P@ssword1234!"

  zones = ["1"]

  upgrade_mode    = "Rolling"
  health_probe_id = azurerm_lb_probe.test.id

  rolling_upgrade_policy {
    cross_zone_upgrades_enabled             = true
    max_batch_instance_percent              = 40
    max_unhealthy_instance_percent          = 40
    max_unhealthy_upgraded_instance_percent = 40
    pause_time_between_batches              = "PT0S"
    prioritize_unhealthy_instances_enabled  = true
  }

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
