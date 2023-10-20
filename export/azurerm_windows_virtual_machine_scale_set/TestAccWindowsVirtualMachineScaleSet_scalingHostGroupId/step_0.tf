

locals {
  vm_name = "acctvm23"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040746320596"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231020040746320596"
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


resource "azurerm_dedicated_host_group" "test" {
  name                        = "acctestDHG-231020040746320596"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  platform_fault_domain_count = 2
  automatic_placement_enabled = true
}

resource "azurerm_dedicated_host" "test" {
  name                    = "acctestDH-231020040746320596"
  dedicated_host_group_id = azurerm_dedicated_host_group.test.id
  location                = azurerm_resource_group.test.location
  sku_name                = "DSv3-Type3"
  platform_fault_domain   = 1
}

resource "azurerm_windows_virtual_machine_scale_set" "test" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_D2s_v3" # NOTE: SKU's are limited by the Dedicated Host
  instances           = 1
  admin_username      = "adminuser"
  admin_password      = "P@ssword1234!"

  platform_fault_domain_count = 1
  host_group_id               = azurerm_dedicated_host_group.test.id

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
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.test.id
    }
  }

  depends_on = [
    azurerm_dedicated_host.test
  ]
}
