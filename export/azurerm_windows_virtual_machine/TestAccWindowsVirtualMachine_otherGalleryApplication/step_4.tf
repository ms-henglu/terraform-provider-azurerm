



locals {
  vm_name = "acctestvm9a6gk"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230602030259376146"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230602030259376146"
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
  name                = "acctestnic-230602030259376146"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_storage_account" "test" {
  name                     = "accteststr9a6gk"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "test"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "test" {
  name                   = "script"
  storage_account_name   = azurerm_storage_account.test.name
  storage_container_name = azurerm_storage_container.test.name
  type                   = "Page"
  size                   = 512
}

resource "azurerm_storage_blob" "test2" {
  name                   = "script2"
  storage_account_name   = azurerm_storage_account.test.name
  storage_container_name = azurerm_storage_container.test.name
  type                   = "Page"
  size                   = 512
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230602030259376146"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_gallery_application" "test" {
  name              = "acctest-app-230602030259376146"
  gallery_id        = azurerm_shared_image_gallery.test.id
  location          = azurerm_shared_image_gallery.test.location
  supported_os_type = "Windows"
}

resource "azurerm_gallery_application_version" "test" {
  name                   = "0.0.1"
  gallery_application_id = azurerm_gallery_application.test.id
  location               = azurerm_gallery_application.test.location

  source {
    media_link                 = azurerm_storage_blob.test.id
    default_configuration_link = azurerm_storage_blob.test.id
  }

  manage_action {
    install = "[install command]"
    remove  = "[remove command]"
  }

  target_region {
    name                   = azurerm_gallery_application.test.location
    regional_replica_count = 1
    storage_account_type   = "Premium_LRS"
  }
}

resource "azurerm_gallery_application" "test2" {
  name              = "acctest-app2-230602030259376146"
  gallery_id        = azurerm_shared_image_gallery.test.id
  location          = azurerm_shared_image_gallery.test.location
  supported_os_type = "Windows"
}

resource "azurerm_gallery_application_version" "test2" {
  name                   = "0.0.1"
  gallery_application_id = azurerm_gallery_application.test2.id
  location               = azurerm_gallery_application.test2.location

  source {
    media_link                 = azurerm_storage_blob.test.id
    default_configuration_link = azurerm_storage_blob.test.id
  }

  manage_action {
    install = "[install command]"
    remove  = "[remove command]"
  }

  target_region {
    name                   = azurerm_gallery_application.test2.location
    regional_replica_count = 1
    storage_account_type   = "Premium_LRS"
  }
}


resource "azurerm_windows_virtual_machine" "test" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
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
}
