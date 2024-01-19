

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-Watcher-240119025527706804"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctest-Watcher-240119025527706804"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-Vnet-240119025527706804"
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

resource "azurerm_network_interface" "src" {
  name                = "acctest-SrcNIC-240119025527706804"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "src" {
  name                  = "acctest-SrcVM-240119025527706804"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  network_interface_ids = [azurerm_network_interface.src.id]
  vm_size               = "Standard_D1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk-src240119025527706804"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  delete_os_disk_on_termination = true

  os_profile {
    computer_name  = "hostname240119025527706804"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_virtual_machine_extension" "src" {
  name                       = "acctest-VMExtension"
  virtual_machine_id         = azurerm_virtual_machine.src.id
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentLinux"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true
}


resource "azurerm_network_connection_monitor" "test" {
  name               = "acctest-CM-240119025527706804"
  network_watcher_id = azurerm_network_watcher.test.id
  location           = azurerm_network_watcher.test.location

  endpoint {
    name               = "source"
    target_resource_id = azurerm_virtual_machine.src.id
  }

  test_configuration {
    name     = "tcp"
    protocol = "Tcp"

    tcp_configuration {
      port = 80
    }
  }

  test_group {
    name                     = "testtg"
    destination_endpoints    = []
    source_endpoints         = ["source"]
    test_configuration_names = ["tcp"]
  }

  depends_on = [azurerm_virtual_machine_extension.src]
}
