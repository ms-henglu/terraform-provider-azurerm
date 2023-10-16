
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034131341164"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctvn-231016034131341164"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctsub-231016034131341164"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_storage_account" "test" {
  name                     = "accsa231016034131341164"
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
  name                = "acctvmss-231016034131341164"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  upgrade_policy_mode = "Manual"

  sku {
    name     = "Standard_D4_v2"
    tier     = "Standard"
    capacity = 2
  }

  os_profile {
    computer_name_prefix = "testvm-231016034131341164"
    admin_username       = "myadmin"
    admin_password       = "Passwword1234"
  }

  network_profile {
    name    = "TestNetworkProfile-231016034131341164"
    primary = true

    dns_settings {
      dns_servers = ["8.8.8.8", "8.8.4.4"]
    }

    ip_configuration {
      name      = "TestIPConfiguration"
      primary   = true
      subnet_id = azurerm_subnet.test.id
    }
  }

  storage_profile_os_disk {
    name           = "osDiskProfile"
    caching        = "ReadWrite"
    create_option  = "FromImage"
    vhd_containers = ["${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}"]
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
