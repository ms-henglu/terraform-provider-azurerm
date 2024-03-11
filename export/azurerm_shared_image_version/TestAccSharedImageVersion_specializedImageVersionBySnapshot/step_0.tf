


provider "azurerm" {
  features {}
}


locals {
  number            = "240311031615619793"
  location          = "West Europe"
  domain_name_label = "acctestvm-n30z3"
  random_string     = "n30z3"
  admin_username    = "testadmin240311031615619793"
  admin_password    = "Password1234!240311031615619793"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-${local.number}"
  location = local.location
}

resource "azurerm_virtual_network" "test" {
  name                = "acctvn-${local.number}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctpip-${local.number}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
  domain_name_label   = local.domain_name_label
}


resource "azurerm_network_interface" "testsource" {
  name                = "acctnicsource-${local.number}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "testconfigurationsource"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test.id
  }
}

resource "azurerm_virtual_machine" "testsource" {
  name                  = "testsource"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  network_interface_ids = [azurerm_network_interface.testsource.id]
  vm_size               = "Standard_D1_v2"

  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  storage_os_disk {
    name          = "myosdisk1"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "mdimagetestsource"
    admin_username = local.admin_username
    admin_password = local.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "Dev"
    cost-center = "Ops"
  }
}


resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig240311031615619793"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg240311031615619793"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  specialized         = true

  identifier {
    publisher = "AccTesPublisher240311031615619793"
    offer     = "AccTesOffer240311031615619793"
    sku       = "AccTesSku240311031615619793"
  }
}


resource "azurerm_snapshot" "test" {
  name                = "acctestsnapshot240311031615619793"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  create_option       = "Copy"
  source_resource_id  = azurerm_virtual_machine.testsource.storage_os_disk.0.managed_disk_id
}

resource "azurerm_shared_image_version" "test" {
  name                = "0.0.1"
  gallery_name        = azurerm_shared_image_gallery.test.name
  image_name          = azurerm_shared_image.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  os_disk_snapshot_id = azurerm_snapshot.test.id

  target_region {
    name                   = azurerm_resource_group.test.location
    regional_replica_count = 1
  }

  tags = {
    "foo" = "bar"
  }
}
