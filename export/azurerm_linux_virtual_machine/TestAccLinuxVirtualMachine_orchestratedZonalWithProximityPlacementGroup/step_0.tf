

locals {
  vm_name = "acctestvmj8enr"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023108406147"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230915023108406147"
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


resource "azurerm_proximity_placement_group" "test" {
  name                = "acctestPPG-230915023108406147"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230915023108406147"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_orchestrated_virtual_machine_scale_set" "test" {
  name                = "acctestVMO-230915023108406147"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  platform_fault_domain_count = 1

  proximity_placement_group_id = azurerm_proximity_placement_group.test.id

  zones = ["1"]

  tags = {
    ENV = "Test"
  }
}

resource "azurerm_linux_virtual_machine" "test" {
  name                            = "acctestVM-230915023108406147"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@ssw0rd1234!"
  disable_password_authentication = false

  proximity_placement_group_id = azurerm_proximity_placement_group.test.id

  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]

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

  virtual_machine_scale_set_id = azurerm_orchestrated_virtual_machine_scale_set.test.id
  zone                         = tolist(azurerm_orchestrated_virtual_machine_scale_set.test.zones)[0]
}
