

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batchjob-230613071418610696"
  location = "west europe"
}

resource "azurerm_batch_account" "test" {
  name                = "testaccbatchyu9x3"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpool-230613071418610696"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  node_agent_sku_id   = "batch.node.ubuntu 18.04"
  vm_size             = "Standard_A1"

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


resource "azurerm_batch_job" "test" {
  name          = "testaccbj-230613071418610696"
  batch_pool_id = azurerm_batch_pool.test.id
  display_name  = "testaccbj-display-230613071418610696"
  common_environment_properties = {
    env       = "Test"
    terraform = "true"
  }
  priority           = 1
  task_retry_maximum = 1
}
