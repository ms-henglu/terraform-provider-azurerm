


locals {
  vm_name = "acctestvmyzsul"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230316221218806757"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230316221218806757"
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


resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230316221218806757"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-ccrg-230316221218806757"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_capacity_reservation" "test" {
  name                          = "acctest-ccr-230316221218806757"
  capacity_reservation_group_id = azurerm_capacity_reservation_group.test.id
  sku {
    name     = "Standard_F2"
    capacity = 1
  }
}

resource "azurerm_capacity_reservation_group" "test2" {
  name                = "acctest-ccrg2-230316221218806757"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_capacity_reservation" "test2" {
  name                          = "acctest-ccr-230316221218806757"
  capacity_reservation_group_id = azurerm_capacity_reservation_group.test2.id
  sku {
    name     = "Standard_F2"
    capacity = 1
  }
}

resource "azurerm_windows_virtual_machine" "test" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"

  capacity_reservation_group_id = azurerm_capacity_reservation_group.test2.id

  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_capacity_reservation.test2,
  ]
}
