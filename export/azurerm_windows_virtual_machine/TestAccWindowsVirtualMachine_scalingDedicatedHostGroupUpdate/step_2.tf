


locals {
  vm_name = "acctestvmjtysg"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063504100180"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105063504100180"
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
  name                = "acctestnic-240105063504100180"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_dedicated_host_group" "test" {
  name                        = "acctestDHG-240105063504100180"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  platform_fault_domain_count = 2
  automatic_placement_enabled = true
}

resource "azurerm_dedicated_host" "test" {
  name                    = "acctestDH-240105063504100180"
  dedicated_host_group_id = azurerm_dedicated_host_group.test.id
  location                = azurerm_resource_group.test.location
  sku_name                = "DSv3-Type3"
  platform_fault_domain   = 1
}

resource "azurerm_windows_virtual_machine" "test" {
  name                    = local.vm_name
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  size                    = "Standard_D2s_v3" # NOTE: SKU's are limited by the Dedicated Host
  admin_username          = "adminuser"
  admin_password          = "P@$$w0rd1234!"
  dedicated_host_group_id = azurerm_dedicated_host_group.test.id
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
    azurerm_dedicated_host.test
  ]
}
