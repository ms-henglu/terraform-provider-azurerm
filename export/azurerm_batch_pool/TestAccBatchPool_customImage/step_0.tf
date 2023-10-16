
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-231016033447860688"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-231016033447860688"
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

resource "azurerm_public_ip" "test" {
  name                = "acctestpip231016033447860688"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
  domain_name_label   = "acctestpip231016033447860688"
}

resource "azurerm_network_interface" "testsource" {
  name                = "acctestnic-231016033447860688"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "testconfigurationsource"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test.id
  }
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaoj1gc"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  allow_nested_items_to_be_public = true

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_storage_container" "test" {
  name                  = "vhds"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "blob"
}

resource "azurerm_virtual_machine" "testsource" {
  name                  = "acctestvm-231016033447860688"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  network_interface_ids = [azurerm_network_interface.testsource.id]
  vm_size               = "Standard_D1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-lts"
    version   = "latest"
  }

  storage_os_disk {
    name          = "myosdisk1"
    vhd_uri       = "${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}/myosdisk1.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
    disk_size_gb  = "30"
  }

  os_profile {
    computer_name  = "acctest-231016033447860688"
    admin_username = "tfuser"
    admin_password = "P@ssW0RD7890"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "Dev"
    cost-center = "Ops"
  }
}

resource "azurerm_image" "test" {
  name                = "acctest-231016033447860688"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = azurerm_virtual_machine.testsource.storage_os_disk[0].vhd_uri
    size_gb  = 30
    caching  = "None"
  }

  tags = {
    environment = "Dev"
    cost-center = "Ops"
  }
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig231016033447860688"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg231016033447860688"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"

  identifier {
    publisher = "AccTesPublisher231016033447860688"
    offer     = "AccTesOffer231016033447860688"
    sku       = "AccTesSku231016033447860688"
  }
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchoj1gc"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"

  tags = {
    env = "test"
  }
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpooloj1gc"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  display_name        = "Test Acc Pool"
  vm_size             = "Standard_A1"
  max_tasks_per_node  = 2
  node_agent_sku_id   = "batch.node.ubuntu 18.04"

  fixed_scale {
    target_dedicated_nodes = 2
  }

  storage_image_reference {
    id = azurerm_shared_image.test.id
  }
}
