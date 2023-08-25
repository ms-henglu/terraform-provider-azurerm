

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230825024120216243"
  location = "West Europe"
}
resource "azurerm_network_security_group" "test" {
  name                = "testnsg-batch-zs66s"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
resource "azurerm_virtual_network" "test" {
  name                = "testvn-batch-zs66s"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}
resource "azurerm_subnet" "testsubnet" {
  name                 = "testsn-zs66s"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = azurerm_subnet.testsubnet.id
  network_security_group_id = azurerm_network_security_group.test.id
}

resource "azurerm_storage_account" "test" {
  name                     = "accbatchsazs66s"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "accbatchsczs66s"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "blob"
}

resource "azurerm_batch_account" "test" {
  name                = "testaccbatchzs66s"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_user_assigned_identity" "test" {
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  name = "testidentityzs66s"
}

resource "azurerm_role_assignment" "blob_contributor" {
  principal_id         = azurerm_user_assigned_identity.test.principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.test.id
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpoolzs66s"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  display_name        = "Test Acc Pool Auto"
  vm_size             = "Standard_A1"
  node_agent_sku_id   = "batch.node.ubuntu 20.04"

  fixed_scale {
    target_dedicated_nodes = 0
  }

  storage_image_reference {
    publisher = "microsoft-azure-batch"
    offer     = "ubuntu-server-container"
    sku       = "20-04-lts"
    version   = "latest"
  }

  mount {
    azure_blob_file_system {
      account_name        = azurerm_storage_account.test.name
      container_name      = azurerm_storage_container.test.name
      relative_mount_path = "/mnt/"
      identity_id         = azurerm_user_assigned_identity.test.id
    }
  }
}
