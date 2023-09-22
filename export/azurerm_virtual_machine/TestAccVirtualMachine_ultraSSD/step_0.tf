
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922061335897915"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctvn-230922061335897915"
  address_space       = ["10.0.0.0/28"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctsub-230922061335897915"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.0.0/29"]
}

resource "azurerm_network_interface" "test" {
  name                = "acctni-230922061335897915"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "test" {
  name                  = "acctvm-230922061335897915"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  network_interface_ids = [azurerm_network_interface.test.id]
  vm_size               = "Standard_D2S_V3"
  zones                 = ["1"]

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  additional_capabilities {
    ultra_ssd_enabled = true
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    os_type           = "Linux"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = "64"
  }

  storage_data_disk {
    name              = "mydatadisk1"
    caching           = "None"
    create_option     = "Empty"
    managed_disk_type = "UltraSSD_LRS"
    disk_size_gb      = "64"
    lun               = 1
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
