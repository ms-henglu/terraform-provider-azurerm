
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-210910021130166394"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "testaccsagmklz"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchgmklz"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
  storage_account_id   = azurerm_storage_account.test.id

  tags = {
    env = "test"
  }
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpoolgmklz"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  display_name        = "Test Acc Pool"
  vm_size             = "Standard_A1"
  max_tasks_per_node  = 2
  node_agent_sku_id   = "batch.node.ubuntu 16.04"

  fixed_scale {
    target_dedicated_nodes = 2
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  metadata = {
    tagName = "Example tag"
  }
}
