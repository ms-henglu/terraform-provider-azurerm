


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230120051914371232"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl230120051914371232"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dev_test_virtual_network" "test" {
  name                = "acctestdtvn230120051914371232"
  lab_name            = azurerm_dev_test_lab.test.name
  resource_group_name = azurerm_resource_group.test.name

  subnet {
    use_public_ip_address           = "Allow"
    use_in_virtual_machine_creation = "Allow"
  }
}


resource "azurerm_dev_test_linux_virtual_machine" "test" {
  name                   = "acctestvm-vm230120051914371232"
  lab_name               = azurerm_dev_test_lab.test.name
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  size                   = "Standard_F2"
  username               = "acct5stU5er"
  password               = "Pa$w0rd1234!"
  lab_virtual_network_id = azurerm_dev_test_virtual_network.test.id
  lab_subnet_name        = azurerm_dev_test_virtual_network.test.subnet[0].name
  storage_type           = "Standard"

  gallery_image_reference {
    offer     = "UbuntuServer"
    publisher = "Canonical"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}


resource "azurerm_dev_test_linux_virtual_machine" "import" {
  name                   = azurerm_dev_test_linux_virtual_machine.test.name
  lab_name               = azurerm_dev_test_linux_virtual_machine.test.lab_name
  resource_group_name    = azurerm_dev_test_linux_virtual_machine.test.resource_group_name
  location               = azurerm_dev_test_linux_virtual_machine.test.location
  size                   = azurerm_dev_test_linux_virtual_machine.test.size
  username               = "acct5stU5er"
  password               = "Pa$w0rd1234!"
  lab_virtual_network_id = azurerm_dev_test_virtual_network.test.id
  lab_subnet_name        = azurerm_dev_test_virtual_network.test.subnet[0].name
  storage_type           = "Standard"

  gallery_image_reference {
    offer     = "UbuntuServer"
    publisher = "Canonical"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
