



# note: whilst these aren't used in all tests, it saves us redefining these everywhere
locals {
  first_public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+wWK73dCr+jgQOAxNsHAnNNNMEMWOHYEccp6wJm2gotpr9katuF/ZAdou5AaW1C61slRkHRkpRRX9FA9CYBiitZgvCCz+3nWNN7l/Up54Zps/pHWGZLHNJZRYyAB6j5yVLMVHIHriY49d/GZTZVNB8GoJv9Gakwc/fuEZYYl4YDFiGMBP///TzlI4jhiJzjKnEvqPFki5p2ZRJqcbCiF4pJrxUQR/RXqVFQdbRLZgYfJ8xGB878RENq3yQ39d8dVOkq4edbkzwcUmwwwkYVPIoDGsYLaRHnG+To7FvMeyO7xDVQkMKzopTQV8AuKpyvpqu0a9pWOMaiCyDytO7GGN you@me.com"
  second_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0/NDMj2wG6bSa6jbn6E3LYlUsYiWMp1CQ2sGAijPALW6OrSu30lz7nKpoh8Qdw7/A4nAJgweI5Oiiw5/BOaGENM70Go+VM8LQMSxJ4S7/8MIJEZQp5HcJZ7XDTcEwruknrd8mllEfGyFzPvJOx6QAQocFhXBW6+AlhM3gn/dvV5vdrO8ihjET2GoDUqXPYC57ZuY+/Fz6W3KV8V97BvNUhpY5yQrP5VpnyvvXNFQtzDfClTvZFPuoHQi3/KYPi6O0FSD74vo8JOBZZY09boInPejkm9fvHQqfh0bnN7B6XJoUwC1Qprrx+XIy7ust5AEn5XL7d4lOvcR14MxDDKEp you@me.com"
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428045412158135"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230428045412158135"
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


resource "azurerm_public_ip" "source" {
  name                = "source-230428045412158135"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "source" {
  name                = "sourcenic-230428045412158135"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "source"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.source.id
  }
}

resource "azurerm_storage_account" "test" {
  name                            = "accsaql2iw"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true
}

resource "azurerm_storage_container" "test" {
  name                  = "vhds"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "blob"
}


resource "azurerm_virtual_machine" "source" {
  name                  = "source"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  network_interface_ids = [azurerm_network_interface.source.id]
  vm_size               = "Standard_F2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "osdisk1"
    vhd_uri       = "${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}/osdisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
    disk_size_gb  = 30
  }

  os_profile {
    computer_name  = "mdimagetestsource"
    admin_username = "mradministrator"
    admin_password = "P@ssword1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
