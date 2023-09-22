


locals {
  vm_name = "acctestvmtx62k"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060812885380"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922060812885380"
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
  name                = "acctestnic-230922060812885380"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_marketplace_agreement" "test" {
  publisher = "plesk"
  offer     = "plesk-onyx-windows"
  plan      = "plsk-win-hst-azr-m"
}

resource "azurerm_windows_virtual_machine" "test" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  plan {
    publisher = "plesk"
    product   = "plesk-onyx-windows"
    name      = "plsk-win-hst-azr-m"
  }

  source_image_reference {
    publisher = "plesk"
    offer     = "plesk-onyx-windows"
    sku       = "plsk-win-hst-azr-m"
    version   = "latest"
  }

  depends_on = ["azurerm_marketplace_agreement.test"]
}
