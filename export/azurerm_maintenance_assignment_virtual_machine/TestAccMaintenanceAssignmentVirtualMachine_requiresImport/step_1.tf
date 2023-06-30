


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-maint-230630033459970403"
  location = "West Europe"
}

resource "azurerm_maintenance_configuration" "test" {
  name                = "acctest-MC230630033459970403"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  scope               = "SQLDB"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230630033459970403"
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
  name                = "acctni-230630033459970403"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "test" {
  name                = "acctestVM-230630033459970403"
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
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}


resource "azurerm_maintenance_assignment_virtual_machine" "test" {
  location                     = azurerm_resource_group.test.location
  maintenance_configuration_id = azurerm_maintenance_configuration.test.id
  virtual_machine_id           = azurerm_linux_virtual_machine.test.id
}


resource "azurerm_maintenance_assignment_virtual_machine" "import" {
  location                     = azurerm_maintenance_assignment_virtual_machine.test.location
  maintenance_configuration_id = azurerm_maintenance_assignment_virtual_machine.test.maintenance_configuration_id
  virtual_machine_id           = azurerm_maintenance_assignment_virtual_machine.test.virtual_machine_id
}
