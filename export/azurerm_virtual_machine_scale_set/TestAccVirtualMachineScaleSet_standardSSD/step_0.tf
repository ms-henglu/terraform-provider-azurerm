
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221202035852255205"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctvn-221202035852255205"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctsub-221202035852255205"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_storage_account" "test" {
  name                     = "accsa221202035852255205"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "test" {
  name                  = "vhds"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_virtual_machine_scale_set" "test" {
  name                   = "acctvmss-221202035852255205"
  location               = azurerm_resource_group.test.location
  resource_group_name    = azurerm_resource_group.test.name
  upgrade_policy_mode    = "Manual"
  single_placement_group = false

  sku {
    name     = "Standard_D1_v2"
    tier     = "Standard"
    capacity = 2
  }

  os_profile {
    computer_name_prefix = "testvm-221202035852255205"
    admin_username       = "myadmin"
    admin_password       = "Passwword1234"
  }

  network_profile {
    name    = "TestNetworkProfile-221202035852255205"
    primary = true

    ip_configuration {
      name      = "TestIPConfiguration"
      primary   = true
      subnet_id = azurerm_subnet.test.id
    }
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
