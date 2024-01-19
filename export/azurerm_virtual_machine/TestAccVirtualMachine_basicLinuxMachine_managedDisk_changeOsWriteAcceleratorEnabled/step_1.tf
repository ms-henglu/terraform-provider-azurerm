
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025233546615"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctvn-240119025233546615"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctsub-240119025233546615"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "test" {
  name                = "acctni-240119025233546615"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "test" {
  name                  = "acctvm-240119025233546615"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  network_interface_ids = [azurerm_network_interface.test.id]
  vm_size               = "Standard_M8ms"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  storage_os_disk {
    name                      = "osd-240119025233546615"
    create_option             = "FromImage"
    caching                   = "None"
    disk_size_gb              = "50"
    managed_disk_type         = "Premium_LRS"
    write_accelerator_enabled = false
  }

  storage_data_disk {
    name              = "acctmd-240119025233546615"
    create_option     = "Empty"
    disk_size_gb      = "1"
    managed_disk_type = "Standard_LRS"
    lun               = 0
  }

  os_profile {
    computer_name  = "hn240119025233546615"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "Production"
    cost-center = "Ops"
  }
}
