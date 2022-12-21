

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-221221204006664982"
  location = "West Europe"
}
resource "azurerm_network_security_group" "test" {
  name                = "testnsg-batch-2jkd8"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
resource "azurerm_virtual_network" "test" {
  name                = "testvn-batch-2jkd8"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}
resource "azurerm_subnet" "testsubnet" {
  name                 = "testsn-2jkd8"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = azurerm_subnet.testsubnet.id
  network_security_group_id = azurerm_network_security_group.test.id
}

resource "azurerm_storage_account" "test" {
  name                     = "accbatchsa2jkd8"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
resource "azurerm_storage_container" "test" {
  name                  = "accbatchsc2jkd8"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "blob"
}
resource "azurerm_batch_account" "test" {
  name                = "testaccbatch2jkd8"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
resource "azurerm_batch_pool" "test" {
  name                = "testaccpool2jkd8"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  node_agent_sku_id   = "batch.node.ubuntu 18.04"
  vm_size             = "Standard_A1"
  mount {
    azure_file_share {
      account_name        = azurerm_storage_account.test.name
      account_key         = azurerm_storage_account.test.primary_access_key
      azure_file_url      = "https://testaccount.file.core.windows.net/"
      relative_mount_path = "/mnt/"
    }
  }
  fixed_scale {
    target_dedicated_nodes = 1
  }
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-lts"
    version   = "latest"
  }
}
