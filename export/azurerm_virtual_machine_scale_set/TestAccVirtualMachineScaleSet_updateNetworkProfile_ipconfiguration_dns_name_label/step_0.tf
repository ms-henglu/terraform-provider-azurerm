
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025233556526"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctvn-240119025233556526"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctsub-240119025233556526"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_storage_account" "test" {
  name                     = "accsa240119025233556526"
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
  name                = "acctvmss-240119025233556526"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  upgrade_policy_mode = "Manual"

  tags = {
    state = "create"
  }

  sku {
    name     = "Standard_D1_v2"
    tier     = "Standard"
    capacity = 0
  }

  os_profile {
    computer_name_prefix = "testvm-240119025233556526"
    admin_username       = "myadmin"
    admin_password       = "Passwword1234"
  }

  network_profile {
    name    = "TestNetworkProfile-240119025233556526"
    primary = true

    ip_configuration {
      name      = "TestIPConfiguration"
      subnet_id = azurerm_subnet.test.id
      primary   = true

      public_ip_address_configuration {
        name              = "TestPublicIPConfiguration"
        domain_name_label = "test-domain-label-240119025233556526"
        idle_timeout      = 4
      }
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
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
