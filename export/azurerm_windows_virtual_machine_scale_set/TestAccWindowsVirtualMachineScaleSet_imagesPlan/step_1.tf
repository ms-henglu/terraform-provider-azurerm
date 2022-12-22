

locals {
  vm_name = "acctvm22"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222034403257621"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-221222034403257621"
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


resource "azurerm_marketplace_agreement" "test" {
  publisher = "plesk"
  offer     = "plesk-onyx-windows"
  plan      = "plsk-win-byol-azr-m"
}

resource "azurerm_windows_virtual_machine_scale_set" "test" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_F2"
  instances           = 1
  admin_username      = "adminuser"
  admin_password      = "P@ssword1234!"

  source_image_reference {
    publisher = "plesk"
    offer     = "plesk-onyx-windows"
    sku       = "plsk-win-byol-azr-m"
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

  plan {
    publisher = "plesk"
    product   = "plesk-onyx-windows"
    name      = "plsk-win-byol-azr-m"
  }

  depends_on = ["azurerm_marketplace_agreement.test"]
}
