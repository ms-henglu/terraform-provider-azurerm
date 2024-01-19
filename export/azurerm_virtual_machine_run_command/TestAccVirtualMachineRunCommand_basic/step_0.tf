
provider "azurerm" {
  features {}
}


variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 240119024707433694
}
variable "random_string" {
  default = "joh2c"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-vmcmd-${var.random_integer}"
  location = var.primary_location
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-${var.random_integer}"
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
  name                = "acctestnic-${var.random_integer}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "test" {
  name                            = "acctestVM-${var.random_integer}"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_B2s"
  admin_username                  = "adminuser"
  admin_password                  = "Pa-${var.random_string}"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestuai-${var.random_integer}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_virtual_machine_run_command" "test" {
  name               = "acctestvmrc-${var.random_string}"
  location           = azurerm_resource_group.test.location
  virtual_machine_id = azurerm_linux_virtual_machine.test.id
  source {
    script = "echo 'hello world'"
  }
}
