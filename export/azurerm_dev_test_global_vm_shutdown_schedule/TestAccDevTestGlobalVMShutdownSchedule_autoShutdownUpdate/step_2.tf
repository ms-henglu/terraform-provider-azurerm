

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtl-240311031936738188"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestVN-240311031936738188"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestSN-240311031936738188"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "test" {
  name                = "acctestNIC-240311031936738188"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "test" {
  name                  = "acctestVM-240311031936738188"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  network_interface_ids = [azurerm_network_interface.test.id]
  size                  = "Standard_B2s"

  admin_username                  = "testadmin"
  admin_password                  = "Password1234!"
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    name                 = "myosdisk-240311031936738188"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}


resource "azurerm_dev_test_global_vm_shutdown_schedule" "test" {
  location           = azurerm_resource_group.test.location
  virtual_machine_id = azurerm_linux_virtual_machine.test.id
  enabled            = false

  daily_recurrence_time = "1100"
  timezone              = "Central Standard Time"

  notification_settings {
    time_in_minutes = 15
    webhook_url     = "https://www.bing.com/2/4"
    email           = "alerts@devtest.com"
    enabled         = true
  }

  tags = {
    Environment = "Production"
  }
}
