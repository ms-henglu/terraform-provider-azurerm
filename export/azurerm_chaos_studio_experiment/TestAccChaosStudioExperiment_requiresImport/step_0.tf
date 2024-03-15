


variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 240315122445316767
}
variable "random_string" {
  default = "77tn7"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-${var.random_integer}"
  location = var.primary_location
}

resource "azurerm_user_assigned_identity" "test" {
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  name = "acctests${var.random_string}"
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
  name                = "acctni-${var.random_integer}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "test" {
  name                = "acctestVM-${var.random_integer}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_chaos_studio_target" "test" {
  location           = azurerm_resource_group.test.location
  target_resource_id = azurerm_linux_virtual_machine.test.id
  target_type        = "Microsoft-VirtualMachine"
}

resource "azurerm_chaos_studio_capability" "test" {
  chaos_studio_target_id = azurerm_chaos_studio_target.test.id
  capability_type        = "Shutdown-1.0"
}

resource "azurerm_chaos_studio_capability" "test2" {
  chaos_studio_target_id = azurerm_chaos_studio_target.test.id
  capability_type        = "Redeploy-1.0"
}


provider "azurerm" {
  features {}
}

resource "azurerm_chaos_studio_experiment" "test" {
  location            = azurerm_resource_group.test.location
  name                = "acctestcse-${var.random_string}"
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "SystemAssigned"
  }

  selectors {
    name                    = "Selector1"
    chaos_studio_target_ids = [azurerm_chaos_studio_target.test.id]
  }

  steps {
    name = "acctestcse-${var.random_string}"
    branch {
      name = "acctestcse-${var.random_string}"
      actions {
        urn           = azurerm_chaos_studio_capability.test.urn
        selector_name = "Selector1"
        parameters = {
          abruptShutdown = "false"
        }
        action_type = "continuous"
        duration    = "PT10M"
      }
    }
  }
}
