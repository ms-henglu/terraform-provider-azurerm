



locals {
  vm_name = "acctvm23"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033604076681"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231016033604076681"
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
  name                = "source-231016033604076681"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "source" {
  name                = "sourcenic-231016033604076681"
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
  name                            = "accsaqc2qs"
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


resource "azurerm_image" "first" {
  name                = "first"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  os_disk {
    os_type  = "Windows"
    os_state = "Generalized"
    blob_uri = "${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}/osdisk.vhd"
    size_gb  = 128
    caching  = "None"
  }
}

resource "azurerm_image" "second" {
  name                = "second"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  os_disk {
    os_type  = "Windows"
    os_state = "Generalized"
    blob_uri = "${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}/osdisk.vhd"
    size_gb  = 128
    caching  = "None"
  }

  depends_on = ["azurerm_image.first"]
}


resource "azurerm_windows_virtual_machine_scale_set" "test" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_F2"
  instances           = 1
  admin_username      = "mradministrator"
  admin_password      = "P@ssword1234!"
  source_image_id     = azurerm_image.second.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    disk_size_gb         = 200
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.test.id
    }
  }
}
