

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064809965612"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl230929064809965612"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dev_test_virtual_network" "test" {
  name                = "acctestdtvn230929064809965612"
  lab_name            = azurerm_dev_test_lab.test.name
  resource_group_name = azurerm_resource_group.test.name

  subnet {
    use_public_ip_address           = "Allow"
    use_in_virtual_machine_creation = "Allow"
  }
}


resource "azurerm_dev_test_windows_virtual_machine" "test" {
  name                   = "acctestvm965612"
  lab_name               = azurerm_dev_test_lab.test.name
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  size                   = "Standard_B1ms"
  username               = "acct5stU5er"
  password               = "Pa$w0rd1234!"
  lab_virtual_network_id = azurerm_dev_test_virtual_network.test.id
  lab_subnet_name        = azurerm_dev_test_virtual_network.test.subnet[0].name
  storage_type           = "Premium"

  gallery_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2012-Datacenter"
    version   = "latest"
  }
}
