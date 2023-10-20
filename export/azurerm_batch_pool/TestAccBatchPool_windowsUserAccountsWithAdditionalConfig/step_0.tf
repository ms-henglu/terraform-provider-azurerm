

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-231020040628871115"
  location = "West Europe"
}
resource "azurerm_network_security_group" "test" {
  name                = "testnsg-batch-n4hun"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
resource "azurerm_virtual_network" "test" {
  name                = "testvn-batch-n4hun"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}
resource "azurerm_subnet" "testsubnet" {
  name                 = "testsn-n4hun"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = azurerm_subnet.testsubnet.id
  network_security_group_id = azurerm_network_security_group.test.id
}

resource "azurerm_batch_account" "test" {
  name                = "testaccbatchn4hun"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
resource "azurerm_batch_pool" "test" {
  name                = "testaccpooln4hun"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  node_agent_sku_id   = "batch.node.windows amd64"
  vm_size             = "Standard_A1"
  fixed_scale {
    target_dedicated_nodes = 1
  }
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }
  license_type = "Windows_Server"
  node_placement {
    policy = "Regional"
  }
  disk_encryption {
    disk_encryption_target = "TemporaryDisk"
  }
  windows {
    enable_automatic_updates = true
  }
  user_accounts {
    name            = "username1"
    password        = "<ExamplePassword>"
    elevation_level = "Admin"
    windows_user_configuration {
      login_mode = "Interactive"
    }
  }
}
