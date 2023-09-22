
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922053821511417"
  location = "westus"
}

data "azurerm_extended_locations" "test" {
  location = azurerm_resource_group.test.location
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922053821511417"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  edge_zone           = data.azurerm_extended_locations.test.extended_locations[0]
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922053821511417"
  location            = azurerm_resource_group.test.location
  edge_zone           = data.azurerm_extended_locations.test.extended_locations[0]
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "test" {
  name                = "acctestvmyt87f"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  size                = "Standard_D2s_v3" # intentional for premium/edgezones
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  edge_zone           = data.azurerm_extended_locations.test.extended_locations[0]
  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
