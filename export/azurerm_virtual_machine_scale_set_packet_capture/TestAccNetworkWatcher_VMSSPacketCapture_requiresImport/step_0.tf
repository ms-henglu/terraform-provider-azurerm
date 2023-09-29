

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-230929065414966160"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestnw-230929065414966160"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_virtual_network" "test" {
  name                = "acctvn-230929065414966160"
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

resource "azurerm_linux_virtual_machine_scale_set" "test" {
  name                 = "acctestvmss-230929065414966160"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  sku                  = "Standard_F2"
  instances            = 4
  admin_username       = "adminuser"
  admin_password       = "P@ssword1234!"
  computer_name_prefix = "my-linux-computer-name-prefix"
  upgrade_mode         = "Automatic"

  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
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
}

resource "azurerm_virtual_machine_scale_set_extension" "test" {
  name                         = "network-watcher"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.test.id
  publisher                    = "Microsoft.Azure.NetworkWatcher"
  type                         = "NetworkWatcherAgentLinux"
  type_handler_version         = "1.4"
  auto_upgrade_minor_version   = true
  automatic_upgrade_enabled    = true
}


resource "azurerm_virtual_machine_scale_set_packet_capture" "test" {
  name                         = "acctestpc-230929065414966160"
  network_watcher_id           = azurerm_network_watcher.test.id
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.test.id

  storage_location {
    file_path = "/var/captures/packet.cap"
  }

  depends_on = [azurerm_virtual_machine_scale_set_extension.test]
}
