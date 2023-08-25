
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024739091495"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctvn-230825024739091495"
  address_space       = ["10.0.0.0/8"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctsub-230825024739091495"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.0.0/16"]
}

resource "azurerm_public_ip" "test" {
  name                    = "acctestpip-230825024739091495"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 4
}

resource "azurerm_lb" "test" {
  name                = "acctestlb-230825024739091495"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_lb_rule" "test" {
  loadbalancer_id                = azurerm_lb.test.id
  name                           = "AccTestLBRule"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.test.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.test.id]
}

resource "azurerm_lb_probe" "test" {
  loadbalancer_id = azurerm_lb.test.id
  name            = "acctest-lb-probe"
  port            = 22
  protocol        = "Tcp"
}

resource "azurerm_lb_backend_address_pool" "test" {
  name            = "acctestbapool"
  loadbalancer_id = azurerm_lb.test.id
}

resource "azurerm_virtual_machine_scale_set" "test" {
  name                = "acctvmss-230825024739091495"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  upgrade_policy_mode  = "Rolling"
  automatic_os_upgrade = true
  health_probe_id      = azurerm_lb_probe.test.id
  depends_on           = [azurerm_lb_rule.test]

  rolling_upgrade_policy {
    max_batch_instance_percent              = 21
    max_unhealthy_instance_percent          = 22
    max_unhealthy_upgraded_instance_percent = 23
    pause_time_between_batches              = "PT30S"
  }

  sku {
    name     = "Standard_F2"
    tier     = "Standard"
    capacity = 1
  }

  os_profile {
    computer_name_prefix = "testvm-230825024739091495"
    admin_username       = "myadmin"
    admin_password       = "Passwword1234"
  }

  network_profile {
    name    = "TestNetworkProfile"
    primary = true

    ip_configuration {
      name                                   = "TestIPConfiguration"
      subnet_id                              = azurerm_subnet.test.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.test.id]
      primary                                = true
    }
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun               = 0
    caching           = "ReadWrite"
    create_option     = "Empty"
    disk_size_gb      = 10
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
