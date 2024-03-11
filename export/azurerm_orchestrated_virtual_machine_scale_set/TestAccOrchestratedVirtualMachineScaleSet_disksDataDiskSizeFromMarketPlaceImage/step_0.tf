
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-OVMSS-240311031615589265"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-240311031615589265"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/8"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsn-240311031615589265"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_lb" "test" {
  name                = "acctestlb-240311031615589265"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku = "Standard"

  frontend_ip_configuration {
    name                          = "default"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "test" {
  name            = "acctestbap-240311031615589265"
  loadbalancer_id = azurerm_lb.test.id
}

resource "azurerm_marketplace_agreement" "barracuda" {
  publisher = "micro-focus"
  offer     = "arcsight-logger"
  plan      = "arcsight_logger_72_byol"
}

resource "azurerm_orchestrated_virtual_machine_scale_set" "test" {
  name                = "acctestOVMSS-240311031615589265"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name  = "Standard_F2"
  instances = 1

  platform_fault_domain_count = 2

  os_profile {

    linux_configuration {
      computer_name_prefix = "testvm-test"
      admin_username       = "myadmin"
      admin_password       = "Passwword1234"

      disable_password_authentication = false
    }
  }

  network_interface {
    name    = "TestNetworkProfile"
    primary = true

    ip_configuration {
      name      = "TestIPConfiguration"
      primary   = true
      subnet_id = azurerm_subnet.test.id

      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.test.id]
    }
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  data_disk {
    caching              = "ReadWrite"
    disk_size_gb         = 900
    create_option        = "FromImage"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "micro-focus"
    offer     = "arcsight-logger"
    sku       = "arcsight_logger_72_byol"
    version   = "7.2.0"
  }

  plan {
    name      = "arcsight_logger_72_byol"
    product   = "arcsight-logger"
    publisher = "micro-focus"
  }
}
