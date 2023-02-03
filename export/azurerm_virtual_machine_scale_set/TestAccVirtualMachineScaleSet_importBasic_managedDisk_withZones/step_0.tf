
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230203063558028512"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctvn-230203063558028512"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctsub-230203063558028512"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_virtual_machine_scale_set" "test" {
  name                = "acctvmss-230203063558028512"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  upgrade_policy_mode = "Manual"
  zones               = ["1", "2"]

  sku {
    name     = "Standard_D1_v2"
    tier     = "Standard"
    capacity = 2
  }

  os_profile {
    computer_name_prefix = "testvm-230203063558028512"
    admin_username       = "myadmin"
    admin_password       = "Passwword1234"
  }

  network_profile {
    name    = "TestNetworkProfile-230203063558028512"
    primary = true

    ip_configuration {
      name      = "TestIPConfiguration"
      primary   = true
      subnet_id = azurerm_subnet.test.id
    }
  }

  storage_profile_os_disk {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
